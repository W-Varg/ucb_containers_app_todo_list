const mongoose = require('mongoose');
const redis = require('redis');
require('dotenv').config();

// Variables de entorno
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://mongodb:27017/todoapp';
const REDIS_URL = process.env.REDIS_URL || 'redis://redis:6379';

// Modelo de Tarea
const TaskSchema = new mongoose.Schema({
  title: String,
  description: String,
  completed: Boolean,
  priority: String,
  createdAt: Date,
  updatedAt: Date,
});

const Task = mongoose.model('Task', TaskSchema);

let redisClient;

// Función principal del worker
async function startWorker() {
  try {
    // Conectar a MongoDB
    await mongoose.connect(MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Worker: MongoDB conectado');

    // Conectar a Redis
    redisClient = redis.createClient({ url: REDIS_URL });
    redisClient.on('error', (err) => console.error('❌ Worker Redis Error:', err));
    await redisClient.connect();
    console.log('✅ Worker: Redis conectado');

    // Iniciar procesamiento periódico
    console.log('🔄 Worker iniciado - Procesando tareas...');
    
    // Procesar tareas cada 30 segundos
    setInterval(async () => {
      await processOldTasks();
      await updateStatistics();
      await cleanupCache();
    }, 30000);

    // También ejecutar inmediatamente
    await processOldTasks();
    await updateStatistics();

  } catch (err) {
    console.error('❌ Error iniciando worker:', err);
    process.exit(1);
  }
}

// Procesar tareas antiguas (marcar como completadas automáticamente después de 24 horas)
async function processOldTasks() {
  try {
    const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const result = await Task.updateMany(
      {
        completed: false,
        createdAt: { $lt: oneDayAgo },
        priority: 'low'
      },
      {
        $set: {
          completed: true,
          updatedAt: new Date(),
          description: 'Auto-completada por el worker (tarea antigua de baja prioridad)'
        }
      }
    );

    if (result.modifiedCount > 0) {
      console.log(`♻️ Worker: ${result.modifiedCount} tareas antiguas procesadas`);
      
      // Invalidar cache
      if (redisClient?.isOpen) {
        await redisClient.del('tasks');
        await redisClient.del('stats');
      }
    }
  } catch (err) {
    console.error('❌ Error procesando tareas antiguas:', err);
  }
}

// Actualizar estadísticas en cache
async function updateStatistics() {
  try {
    const total = await Task.countDocuments();
    const completed = await Task.countDocuments({ completed: true });
    const pending = total - completed;
    const highPriority = await Task.countDocuments({ priority: 'high', completed: false });

    const stats = {
      total,
      completed,
      pending,
      highPriority,
      completionRate: total > 0 ? ((completed / total) * 100).toFixed(2) : 0,
      lastUpdate: new Date().toISOString(),
    };

    // Guardar en Redis
    if (redisClient?.isOpen) {
      await redisClient.setEx('stats', 300, JSON.stringify(stats));
      console.log(`📊 Worker: Estadísticas actualizadas - Total: ${total}, Completadas: ${completed}, Pendientes: ${pending}`);
    }
  } catch (err) {
    console.error('❌ Error actualizando estadísticas:', err);
  }
}

// Limpiar cache expirado
async function cleanupCache() {
  try {
    if (redisClient?.isOpen) {
      const keys = await redisClient.keys('temp:*');
      if (keys.length > 0) {
        await Promise.all(keys.map(key => redisClient.del(key)));
        console.log(`🧹 Worker: ${keys.length} claves temporales limpiadas`);
      }
    }
  } catch (err) {
    console.error('❌ Error limpiando cache:', err);
  }
}

// Función para notificar tareas de alta prioridad pendientes
async function notifyHighPriorityTasks() {
  try {
    const highPriorityTasks = await Task.find({
      priority: 'high',
      completed: false,
    }).countDocuments();

    if (highPriorityTasks > 0) {
      console.log(`⚠️ Worker: ${highPriorityTasks} tareas de alta prioridad pendientes`);
      
      // Aquí podrías enviar notificaciones por email, Slack, etc.
      if (redisClient?.isOpen) {
        await redisClient.setEx('alerts:high_priority', 300, highPriorityTasks.toString());
      }
    }
  } catch (err) {
    console.error('❌ Error notificando tareas de alta prioridad:', err);
  }
}

// Manejo de señales para cierre graceful
process.on('SIGTERM', async () => {
  console.log('🛑 Worker: SIGTERM recibido, cerrando...');
  if (redisClient?.isOpen) {
    await redisClient.quit();
  }
  await mongoose.connection.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('🛑 Worker: SIGINT recibido, cerrando...');
  if (redisClient?.isOpen) {
    await redisClient.quit();
  }
  await mongoose.connection.close();
  process.exit(0);
});

// Health check cada minuto
setInterval(async () => {
  const mongoStatus = mongoose.connection.readyState === 1 ? '✅' : '❌';
  const redisStatus = redisClient?.isOpen ? '✅' : '❌';
  console.log(`💓 Worker Health: MongoDB ${mongoStatus} | Redis ${redisStatus}`);
}, 60000);

// Iniciar worker
startWorker();
