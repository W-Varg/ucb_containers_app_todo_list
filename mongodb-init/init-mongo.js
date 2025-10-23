// Script de inicialización para MongoDB
// Este script crea la base de datos y una colección inicial con datos de ejemplo

print('🚀 Iniciando script de inicialización de MongoDB...');

// Cambiar a la base de datos todoapp
db = db.getSiblingDB('todoapp');

print('✅ Base de datos "todoapp" seleccionada');

// Crear colección de tareas si no existe
db.createCollection('tasks');

print('✅ Colección "tasks" creada');

// Insertar datos de ejemplo
const tasksData = [
  {
    title: 'Bienvenido a la aplicación ToDo',
    description: 'Esta es una tarea de ejemplo creada durante la inicialización',
    completed: false,
    priority: 'high',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: 'Completar examen final de Containerización',
    description: 'Implementar Docker Compose, Swarm y Kubernetes',
    completed: false,
    priority: 'high',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: 'Documentar el proyecto',
    description: 'Crear README con instrucciones y diagramas',
    completed: false,
    priority: 'medium',
    createdAt: new Date(),
    updatedAt: new Date()
  },
  {
    title: 'Subir imágenes a Docker Hub',
    description: 'Publicar todas las imágenes en un repositorio público',
    completed: false,
    priority: 'medium',
    createdAt: new Date(),
    updatedAt: new Date()
  }
];

db.tasks.insertMany(tasksData);

print('✅ ' + tasksData.length + ' tareas de ejemplo insertadas');

// Crear índices para mejorar el rendimiento
db.tasks.createIndex({ createdAt: -1 });
db.tasks.createIndex({ completed: 1 });
db.tasks.createIndex({ priority: 1 });

print('✅ Índices creados exitosamente');

// Mostrar estadísticas
const count = db.tasks.countDocuments();
print('📊 Total de tareas en la base de datos: ' + count);

print('✅ Inicialización de MongoDB completada exitosamente!');
