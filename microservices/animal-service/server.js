const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');

const app = express();
const PORT = process.env.PORT || 3003;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// Временная база данных в памяти
let animals = [
  {
    id: '1',
    name: 'Барсик',
    type: 'Кот',
    age: 3,
    description: 'Дружелюбный рыжий кот',
    imageUrl: 'https://example.com/cat1.jpg',
    isAdopted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '2',
    name: 'Рекс',
    type: 'Собака',
    age: 5,
    description: 'Активная собака породы лабрадор',
    imageUrl: 'https://example.com/dog1.jpg',
    isAdopted: false,
    createdAt: new Date().toISOString()
  },
  {
    id: '3',
    name: 'Мурка',
    type: 'Кошка',
    age: 2,
    description: 'Спокойная серая кошка',
    imageUrl: 'https://example.com/cat2.jpg',
    isAdopted: true,
    createdAt: new Date().toISOString()
  }
];

// Routes

// Получить всех животных
app.get('/api/animals', (req, res) => {
  try {
    const { adopted } = req.query;
    let filteredAnimals = animals;
    
    if (adopted !== undefined) {
      const isAdopted = adopted === 'true';
      filteredAnimals = animals.filter(animal => animal.isAdopted === isAdopted);
    }
    
    res.json({
      success: true,
      data: filteredAnimals,
      count: filteredAnimals.length
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при получении списка животных',
      error: error.message
    });
  }
});

// Получить животное по ID
app.get('/api/animals/:id', (req, res) => {
  try {
    const { id } = req.params;
    const animal = animals.find(a => a.id === id);
    
    if (!animal) {
      return res.status(404).json({
        success: false,
        message: 'Животное не найдено'
      });
    }
    
    res.json({
      success: true,
      data: animal
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при получении животного',
      error: error.message
    });
  }
});

// Добавить новое животное
app.post('/api/animals', (req, res) => {
  try {
    const { name, type, age, description, imageUrl } = req.body;
    
    if (!name || !type || !age) {
      return res.status(400).json({
        success: false,
        message: 'Обязательные поля: name, type, age'
      });
    }
    
    const newAnimal = {
      id: uuidv4(),
      name,
      type,
      age: parseInt(age),
      description: description || '',
      imageUrl: imageUrl || '',
      isAdopted: false,
      createdAt: new Date().toISOString()
    };
    
    animals.push(newAnimal);
    
    res.status(201).json({
      success: true,
      data: newAnimal,
      message: 'Животное успешно добавлено'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при добавлении животного',
      error: error.message
    });
  }
});

// Обновить информацию о животном
app.put('/api/animals/:id', (req, res) => {
  try {
    const { id } = req.params;
    const { name, type, age, description, imageUrl, isAdopted } = req.body;
    
    const animalIndex = animals.findIndex(a => a.id === id);
    
    if (animalIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Животное не найдено'
      });
    }
    
    // Обновляем только переданные поля
    if (name !== undefined) animals[animalIndex].name = name;
    if (type !== undefined) animals[animalIndex].type = type;
    if (age !== undefined) animals[animalIndex].age = parseInt(age);
    if (description !== undefined) animals[animalIndex].description = description;
    if (imageUrl !== undefined) animals[animalIndex].imageUrl = imageUrl;
    if (isAdopted !== undefined) animals[animalIndex].isAdopted = isAdopted;
    
    res.json({
      success: true,
      data: animals[animalIndex],
      message: 'Информация о животном обновлена'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при обновлении животного',
      error: error.message
    });
  }
});

// Удалить животное
app.delete('/api/animals/:id', (req, res) => {
  try {
    const { id } = req.params;
    const animalIndex = animals.findIndex(a => a.id === id);
    
    if (animalIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Животное не найдено'
      });
    }
    
    const deletedAnimal = animals.splice(animalIndex, 1)[0];
    
    res.json({
      success: true,
      data: deletedAnimal,
      message: 'Животное удалено'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Ошибка при удалении животного',
      error: error.message
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    service: 'animal-service',
    timestamp: new Date().toISOString(),
    port: PORT
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

app.listen(PORT, () => {
  console.log(`🐾 Animal Service запущен на порту ${PORT}`);
  console.log(`📋 API доступен по адресу: http://localhost:${PORT}/api/animals`);
  console.log(`❤️  Health check: http://localhost:${PORT}/health`);
});