const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const WebSocket = require('ws');
const http = require('http');

const app = express();
const PORT = process.env.PORT || 3004;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Создаем HTTP сервер
const server = http.createServer(app);

// Создаем WebSocket сервер
const wss = new WebSocket.Server({ server });

// Временная база данных в памяти
let notifications = [
  {
    id: '1',
    title: 'Новое животное',
    message: 'В приют поступил новый питомец - котенок Мурзик',
    type: 'info',
    isRead: false,
    createdAt: new Date(Date.now() - 86400000).toISOString() // 1 день назад
  },
  {
    id: '2',
    title: 'Успешное усыновление',
    message: 'Собака Рекс нашла новый дом!',
    type: 'success',
    isRead: false,
    createdAt: new Date(Date.now() - 43200000).toISOString() // 12 часов назад
  },
  {
    id: '3',
    title: 'Требуется помощь',
    message: 'Кошке Мурке нужна срочная медицинская помощь',
    type: 'warning',
    isRead: true,
    createdAt: new Date(Date.now() - 21600000).toISOString() // 6 часов назад
  }
];

// WebSocket соединения
const clients = new Set();

// WebSocket обработчики
wss.on('connection', (ws) => {
  console.log('Новое WebSocket соединение');
  clients.add(ws);
  
  // Отправляем приветственное сообщение
  ws.send(JSON.stringify({
    type: 'connection',
    message: 'Подключение к сервису уведомлений установлено'
  }));
  
  ws.on('close', () => {
    console.log('WebSocket соединение закрыто');
    clients.delete(ws);
  });
  
  ws.on('error', (error) => {
    console.error('WebSocket ошибка:', error);
    clients.delete(ws);
  });
});

// Функция для отправки уведомления всем подключенным клиентам
function broadcastNotification(notification) {
  const message = JSON.stringify({
    type: 'notification',
    data: notification
  });
  
  clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  });
}

// Routes

// Получить все уведомления
app.get('/api/notifications', (req, res) => {
  try {
    const { unread, limit } = req.query;
    let filteredNotifications = [...notifications];
    
    // Фильтр по непрочитанным
    if (unread === 'true') {
      filteredNotifications = filteredNotifications.filter(n => !n.isRead);
    }
    
    // Сортировка по дате создания (новые первыми)
    filteredNotifications.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    
    // Ограничение количества
    if (limit) {
      const limitNum = parseInt(limit);
      if (!isNaN(limitNum) && limitNum > 0) {
        filteredNotifications = filteredNotifications.slice(0, limitNum);
      }
    }
    
    res.json({
      success: true,
      data: filteredNotifications,
      count: filteredNotifications.length,
      unreadCount: notifications.filter(n => !n.isRead).length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при получении уведомлений',
      error: error.message
    });
  }
});

// Получить уведомление по ID
app.get('/api/notifications/:id', (req, res) => {
  try {
    const { id } = req.params;
    const notification = notifications.find(n => n.id === id);
    
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Уведомление не найдено'
      });
    }
    
    res.json({
      success: true,
      data: notification
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при получении уведомления',
      error: error.message
    });
  }
});

// Создать новое уведомление
app.post('/api/notifications', (req, res) => {
  try {
    const { title, message, type = 'info' } = req.body;
    
    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Обязательные поля: title, message'
      });
    }
    
    const validTypes = ['info', 'success', 'warning', 'error'];
    if (!validTypes.includes(type)) {
      return res.status(400).json({
        success: false,
        message: 'Недопустимый тип уведомления. Доступные: ' + validTypes.join(', ')
      });
    }
    
    const newNotification = {
      id: uuidv4(),
      title,
      message,
      type,
      isRead: false,
      createdAt: new Date().toISOString()
    };
    
    notifications.unshift(newNotification); // Добавляем в начало массива
    
    // Отправляем уведомление всем подключенным клиентам
    broadcastNotification(newNotification);
    
    res.status(201).json({
      success: true,
      data: newNotification,
      message: 'Уведомление создано'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при создании уведомления',
      error: error.message
    });
  }
});

// Отметить уведомление как прочитанное
app.patch('/api/notifications/:id/read', (req, res) => {
  try {
    const { id } = req.params;
    const notificationIndex = notifications.findIndex(n => n.id === id);
    
    if (notificationIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Уведомление не найдено'
      });
    }
    
    notifications[notificationIndex].isRead = true;
    
    res.json({
      success: true,
      data: notifications[notificationIndex],
      message: 'Уведомление отмечено как прочитанное'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при обновлении уведомления',
      error: error.message
    });
  }
});

// Отметить все уведомления как прочитанные
app.patch('/api/notifications/read-all', (req, res) => {
  try {
    notifications.forEach(notification => {
      notification.isRead = true;
    });
    
    res.json({
      success: true,
      message: 'Все уведомления отмечены как прочитанные',
      count: notifications.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при обновлении уведомлений',
      error: error.message
    });
  }
});

// Удалить уведомление
app.delete('/api/notifications/:id', (req, res) => {
  try {
    const { id } = req.params;
    const notificationIndex = notifications.findIndex(n => n.id === id);
    
    if (notificationIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Уведомление не найдено'
      });
    }
    
    const deletedNotification = notifications.splice(notificationIndex, 1)[0];
    
    res.json({
      success: true,
      data: deletedNotification,
      message: 'Уведомление удалено'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при удалении уведомления',
      error: error.message
    });
  }
});

// Получить статистику уведомлений
app.get('/api/notifications/stats', (req, res) => {
  try {
    const total = notifications.length;
    const unread = notifications.filter(n => !n.isRead).length;
    const read = total - unread;
    
    const typeStats = notifications.reduce((acc, notification) => {
      acc[notification.type] = (acc[notification.type] || 0) + 1;
      return acc;
    }, {});
    
    res.json({
      success: true,
      data: {
        total,
        read,
        unread,
        typeStats,
        connectedClients: clients.size
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при получении статистики',
      error: error.message
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'notification-service',
    timestamp: new Date().toISOString(),
    port: PORT,
    websocketClients: clients.size
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint не найден'
  });
});

// Error handler
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(500).json({
    success: false,
    message: 'Внутренняя ошибка сервера',
    error: process.env.NODE_ENV === 'development' ? error.message : undefined
  });
});

server.listen(PORT, () => {
  console.log(`🔔 Notification Service запущен на порту ${PORT}`);
  console.log(`📋 API доступен по адресу: http://localhost:${PORT}/api/notifications`);
  console.log(`🌐 WebSocket сервер: ws://localhost:${PORT}`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health`);
});