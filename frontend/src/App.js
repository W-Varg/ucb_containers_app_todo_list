import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

function App() {
  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`${API_URL}/tasks`);
      setTasks(response.data);
      setError('');
    } catch (err) {
      setError('Error al cargar las tareas: ' + err.message);
      console.error('Error fetching tasks:', err);
    } finally {
      setLoading(false);
    }
  };

  const addTask = async (e) => {
    e.preventDefault();
    if (!newTask.trim()) return;

    try {
      setLoading(true);
      const response = await axios.post(`${API_URL}/tasks`, {
        title: newTask,
        description: `Tarea creada el ${new Date().toLocaleString()}`,
      });
      setTasks([...tasks, response.data]);
      setNewTask('');
      setError('');
    } catch (err) {
      setError('Error al crear la tarea: ' + err.message);
      console.error('Error adding task:', err);
    } finally {
      setLoading(false);
    }
  };

  const toggleTask = async (id, completed) => {
    try {
      const response = await axios.put(`${API_URL}/tasks/${id}`, {
        completed: !completed,
      });
      setTasks(tasks.map((task) => (task._id === id ? response.data : task)));
      setError('');
    } catch (err) {
      setError('Error al actualizar la tarea: ' + err.message);
      console.error('Error updating task:', err);
    }
  };

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_URL}/tasks/${id}`);
      setTasks(tasks.filter((task) => task._id !== id));
      setError('');
    } catch (err) {
      setError('Error al eliminar la tarea: ' + err.message);
      console.error('Error deleting task:', err);
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>📝 ToDo App - UCB Final Project</h1>
        <p className="subtitle">Containerización y Orquestación - Versión 1.0</p>
      </header>

      <main className="container">
        {error && <div className="error-message">{error}</div>}

        <form onSubmit={addTask} className="add-task-form">
          <input
            type="text"
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            placeholder="Escribe una nueva tarea..."
            disabled={loading}
            className="task-input"
          />
          <button type="submit" disabled={loading} className="add-button">
            {loading ? '⏳' : '➕'} Agregar
          </button>
        </form>

        <div className="tasks-container">
          <h2>Tareas ({tasks.length})</h2>
          {loading && tasks.length === 0 ? (
            <p className="loading">Cargando tareas...</p>
          ) : tasks.length === 0 ? (
            <p className="no-tasks">No hay tareas. ¡Agrega una nueva!</p>
          ) : (
            <ul className="tasks-list">
              {tasks.map((task) => (
                <li key={task._id} className={`task-item ${task.completed ? 'completed' : ''}`}>
                  <div className="task-content">
                    <input
                      type="checkbox"
                      checked={task.completed}
                      onChange={() => toggleTask(task._id, task.completed)}
                      className="task-checkbox"
                    />
                    <div className="task-details">
                      <h3>{task.title}</h3>
                      <p>{task.description}</p>
                      <small>
                        Creada: {new Date(task.createdAt).toLocaleString()}
                      </small>
                    </div>
                  </div>
                  <button
                    onClick={() => deleteTask(task._id)}
                    className="delete-button"
                    title="Eliminar tarea"
                  >
                    🗑️
                  </button>
                </li>
              ))}
            </ul>
          )}
        </div>

        <footer className="app-footer">
          <p> Dockerizado | Orquestado | Kubernetes Ready</p>
        </footer>
      </main>
    </div>
  );
}

export default App;
