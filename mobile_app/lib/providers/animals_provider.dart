import 'package:flutter/foundation.dart';
import '../models/animal.dart';
import '../services/microservices_client.dart';

class AnimalsProvider with ChangeNotifier {
  final MicroservicesClient _client = MicroservicesClient();
  List<Animal> _animals = [];
  List<Animal> _filteredAnimals = [];
  bool _isLoading = false;
  String? _error;

  List<Animal> get animals => 
      _filteredAnimals.isEmpty ? _animals : _filteredAnimals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAnimals({
    String? species,
    bool? isAdopted,
    String? search,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Fetching animals with params: species=$species, isAdopted=$isAdopted, search=$search');

      // Получаем данные из микросервиса
      final animalsData = await _client.getAnimals(
        species: species,
        status: isAdopted == true 
            ? 'adopted' 
            : (isAdopted == false ? 'available' : null),
      );
      
      debugPrint('Received ${animalsData.length} animals from API');
      
      // Преобразуем данные в модели Animal
      _animals = animalsData.map(_convertToAnimal).toList();
      
      debugPrint('Converted to ${_animals.length} Animal objects');
      
      // Применяем поисковый фильтр локально
      _applySearchFilter(search);
      
      debugPrint('Final animals count: ${_animals.length}, filtered: ${_filteredAnimals.length}');
      
    } on Exception catch (e) {
      _error = 'Ошибка загрузки животных: ${e.toString()}';
      _animals = [];
      _filteredAnimals = [];
      debugPrint('Error fetching animals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applySearchFilter(String? search) {
    if (search?.isEmpty ?? true) {
      _filteredAnimals = _animals; // Показываем все животные если поиск пустой
      return;
    }
    
    final searchLower = search!.toLowerCase();
    _filteredAnimals = _animals.where((animal) => 
      animal.name.toLowerCase().contains(searchLower) ||
      animal.description.toLowerCase().contains(searchLower) ||
      animal.species.toLowerCase().contains(searchLower) ||
      (animal.breed?.toLowerCase().contains(searchLower) ?? false)
    ).toList();
  }

  // Конвертируем данные из микросервиса в модель Animal
  Animal _convertToAnimal(Map<String, dynamic> data) {
    debugPrint('Converting animal data: $data');
    return Animal(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      species: data['type']?.toString() ?? data['species']?.toString() ?? '', // Сервер использует 'type'
      breed: data['breed']?.toString() ?? '',
      age: (data['age'] as num?)?.toInt() ?? 0,
      gender: data['gender']?.toString() ?? 'Неизвестно',
      description: data['description']?.toString() ?? '',
      imageUrls: [], // Пока нет изображений в микросервисе
      shelterId: data['shelter']?.toString() ?? '',
      shelterName: data['shelter']?.toString() ?? '',
      shelterAddress: '',
      isAdopted: data['isAdopted'] == true, // Сервер использует 'isAdopted'
      isFavorite: false, // Пока не реализовано в микросервисе
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isVaccinated: data['medicalInfo']?['vaccinated'] == true,
      isNeutered: data['medicalInfo']?['sterilized'] == true,
      medicalHistory: data['medicalInfo']?['healthStatus']?.toString(),
      temperament: null,
      weight: null,
    );
  }

  // Добавить новое животное
  Future<bool> addAnimal({
    required String name,
    required String species,
    required int age,
    required String description,
    String? breed,
    String? color,
    String? gender,
    String? status,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _client.addAnimal(
        name: name,
        species: species,
        age: age,
        description: description,
        breed: breed,
        color: color,
        gender: gender,
        status: status,
      );

      // Обновляем список животных
      await fetchAnimals();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error adding animal: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Усыновить животное
  Future<bool> adoptAnimal({
    required String animalId,
    required String adopterName,
    required String adopterEmail,
    required String adopterPhone,
  }) async {
    try {
      await _client.adoptAnimal(
        animalId: animalId,
        adopterName: adopterName,
        adopterEmail: adopterEmail,
        adopterPhone: adopterPhone,
      );

      // Обновляем список животных
      await fetchAnimals();
      return true;
    } on Exception catch (e) {
      _error = e.toString();
      debugPrint('Error adopting animal: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(String animalId) async {
    // Пока не реализовано в микросервисах
    // Можно добавить локальное хранение избранного
    debugPrint('Favorite functionality not implemented with microservices yet');
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}