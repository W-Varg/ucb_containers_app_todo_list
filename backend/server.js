const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const redis = require('redis');
require('dotenv').config();

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Variables de entorno
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://mongodb:27017/todoapp';
const REDIS_URL = process.env.REDIS_URL || 'redis://redis:6379';

// Conexión a MongoDB
mongoose.connect(MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
  .then(() => console.log('MongoDB conectado exitosamente'))
  .catch((err) => console.error('❌ Error conectando a MongoDB:', err));

// Conexión a Redis
let redisClient;
(async () => {
  try {
    redisClient = redis.createClient({ url: REDIS_URL });
    redisClient.on('error', (err) => console.error('❌ Redis Error:', err));
    await redisClient.connect();
    console.log('Redis conectado exitosamente');
  } catch (err) {
    console.error('❌ Error conectando a Redis:', err);
  }
})();

// docs: Version 1.1.0 - Mejoras implementadas:
// - Sistema de cache optimizado con Redis
// - Mejores logs de operaciones
// - Health check mejorado con información de versión

// Modelo de Tarea
const TaskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    trim: true,
  },
  completed: {
    type: Boolean,
    default: false,
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high'],
    default: 'medium',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

const Task = mongoose.model('Task', TaskSchema);

// Rutas

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    mongodb: mongoose.connection.readyState === 1 ? 'connected' : 'disconnected',
    redis: redisClient?.isOpen ? 'connected' : 'disconnected',
    version: '1.2.0',
    message: 'Backend v1.2.0 - Optimizaciones y mejoras de estabilidad',
    timestamp: new Date().toISOString(),
  });
});

// Obtener todas las tareas
app.get('/api/tasks', async (req, res) => {
  try {
    // Intentar obtener del cache
    if (redisClient?.isOpen) {
      const cached = await redisClient.get('tasks');
      if (cached) {
        console.log('📦 Tareas obtenidas desde cache Redis');
        return res.json(JSON.parse(cached));
      }
    }

    // Obtener de MongoDB
    const tasks = await Task.find().sort({ createdAt: -1 });
    
    // Guardar en cache
    if (redisClient?.isOpen) {
      await redisClient.setEx('tasks', 60, JSON.stringify(tasks));
      console.log('💾 Tareas guardadas en cache Redis');
    }

    res.json(tasks);
  } catch (err) {
    console.error('Error obteniendo tareas:', err);
    res.status(500).json({ error: 'Error al obtener las tareas', details: err.message });
  }
});

// Obtener una tarea por ID
app.get('/api/tasks/:id', async (req, res) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) {
      return res.status(404).json({ error: 'Tarea no encontrada' });
    }
    res.json(task);
  } catch (err) {
    console.error('Error obteniendo tarea:', err);
    res.status(500).json({ error: 'Error al obtener la tarea', details: err.message });
  }
});

// Crear una nueva tarea
app.post('/api/tasks', async (req, res) => {
  try {
    const { title, description, priority } = req.body;

    if (!title) {
      return res.status(400).json({ error: 'El título es requerido' });
    }

    const task = new Task({
      title,
      description,
      priority: priority || 'medium',
    });

    await task.save();

    // Invalidar cache
    if (redisClient?.isOpen) {
      await redisClient.del('tasks');
    }

    console.log('Nueva tarea creada:', task._id);
    res.status(201).json(task);
  } catch (err) {
    console.error('Error creando tarea:', err);
    res.status(500).json({ error: 'Error al crear la tarea', details: err.message });
  }
});

// Actualizar una tarea
app.put('/api/tasks/:id', async (req, res) => {
  try {
    const { title, description, completed, priority } = req.body;

    const task = await Task.findByIdAndUpdate(
      req.params.id,
      {
        title,
        description,
        completed,
        priority,
        updatedAt: Date.now(),
      },
      { new: true, runValidators: true }
    );

    if (!task) {
      return res.status(404).json({ error: 'Tarea no encontrada' });
    }

    // Invalidar cache
    if (redisClient?.isOpen) {
      await redisClient.del('tasks');
    }

    console.log('Tarea actualizada:', task._id);
    res.json(task);
  } catch (err) {
    console.error('Error actualizando tarea:', err);
    res.status(500).json({ error: 'Error al actualizar la tarea', details: err.message });
  }
});

// Eliminar una tarea
app.delete('/api/tasks/:id', async (req, res) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);

    if (!task) {
      return res.status(404).json({ error: 'Tarea no encontrada' });
    }

    // Invalidar cache
    if (redisClient?.isOpen) {
      await redisClient.del('tasks');
    }

    console.log('🗑️ Tarea eliminada:', task._id);
    res.json({ message: 'Tarea eliminada exitosamente', task });
  } catch (err) {
    console.error('Error eliminando tarea:', err);
    res.status(500).json({ error: 'Error al eliminar la tarea', details: err.message });
  }
});

// Estadísticas
app.get('/api/stats', async (req, res) => {
  try {
    const total = await Task.countDocuments();
    const completed = await Task.countDocuments({ completed: true });
    const pending = total - completed;

    res.json({
      total,
      completed,
      pending,
      completionRate: total > 0 ? ((completed / total) * 100).toFixed(2) : 0,
    });
  } catch (err) {
    console.error('Error obteniendo estadísticas:', err);
    res.status(500).json({ error: 'Error al obtener estadísticas', details: err.message });
  }
});

// Manejo de rutas no encontradas
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Servidor backend ejecutándose en puerto ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Manejo de cierre graceful
process.on('SIGTERM', async () => {
  console.log('🛑 SIGTERM recibido, cerrando servidor...');
  if (redisClient?.isOpen) {
    await redisClient.quit();
  }
  await mongoose.connection.close();
  process.exit(0);
});
