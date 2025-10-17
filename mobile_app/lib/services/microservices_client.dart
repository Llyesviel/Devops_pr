import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class MicroservicesClient {
  MicroservicesClient() {
    _dio = Dio();
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static const String _animalServiceUrl = 'http://10.0.2.2:3003';
  static const String _notificationServiceUrl = 'http://10.0.2.2:3004';
  
  late final Dio _dio;

  // Получить список животных
  Future<List<Map<String, dynamic>>> getAnimals({
    int? limit,
    int? offset,
    String? species,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) {
        queryParams['limit'] = limit;
      }
      if (offset != null) {
        queryParams['offset'] = offset;
      }
      if (species != null) {
        queryParams['species'] = species;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      debugPrint('Making request to: $_animalServiceUrl/api/animals with params: $queryParams');

      final response = await _dio.get<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals',
        queryParameters: queryParams,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.data != null && response.data!['data'] is List) {
        final animals = List<Map<String, dynamic>>.from(
          response.data!['data'] as List
        );
        debugPrint('Returning ${animals.length} animals');
        return animals;
      }
      debugPrint('No animals found in response or invalid format');
      return [];
    } on DioException catch (e) {
      debugPrint('Ошибка при получении животных: ${e.message}');
      debugPrint('Response: ${e.response?.data}');
      throw Exception('Не удалось получить список животных: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Добавить новое животное
  Future<Map<String, dynamic>> addAnimal({
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
      final animalData = {
        'name': name,
        'type': species, // Сервер ожидает 'type' вместо 'species'
        'age': age,
        'description': description,
        if (breed != null) 'breed': breed,
        if (color != null) 'color': color,
        if (gender != null) 'gender': gender,
        if (status != null) 'status': status,
      };

      final response = await _dio.post(
        '$_animalServiceUrl/api/animals',
        data: animalData,
      );

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Не удалось добавить животное');
    } on DioException catch (e) {
      debugPrint('Ошибка при добавлении животного: ${e.message}');
      throw Exception('Не удалось добавить животное: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Получить животное по ID
  Future<Map<String, dynamic>?> getAnimalById(String id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals/$id',
      );

      if (response.data != null && response.data!['success'] == true) {
        return response.data!['animal'] as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Ошибка при получении животного: ${e.message}');
      throw Exception('Не удалось получить данные животного: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Обновить данные животного
  Future<Map<String, dynamic>> updateAnimal(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals/$id',
        data: updates,
      );

      if (response.data != null && response.data!['success'] == true) {
        return response.data!['animal'] as Map<String, dynamic>;
      }
      throw Exception('Не удалось обновить данные животного');
    } on DioException catch (e) {
      debugPrint('Ошибка при обновлении животного: ${e.message}');
      throw Exception('Не удалось обновить животное: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Удалить животное
  Future<void> deleteAnimal(String id) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals/$id',
      );

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Не удалось удалить животное');
      }
    } on DioException catch (e) {
      debugPrint('Ошибка при удалении животного: ${e.message}');
      throw Exception('Не удалось удалить животное: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Усыновить животное
  Future<Map<String, dynamic>> adoptAnimal({
    required String animalId,
    required String adopterName,
    required String adopterEmail,
    required String adopterPhone,
  }) async {
    try {
      final adoptionData = {
        'adopterName': adopterName,
        'adopterEmail': adopterEmail,
        'adopterPhone': adopterPhone,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals/$animalId/adopt',
        data: adoptionData,
      );

      if (response.data != null && response.data!['success'] == true) {
        return response.data!['adoption'] as Map<String, dynamic>;
      }
      throw Exception('Не удалось усыновить животное');
    } on DioException catch (e) {
      debugPrint('Ошибка при усыновлении животного: ${e.message}');
      throw Exception('Не удалось усыновить животное: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Получить статистику животных
  Future<Map<String, dynamic>> getAnimalStats() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_animalServiceUrl/api/animals/stats',
      );

      if (response.data != null && response.data!['success'] == true) {
        return response.data!['stats'] as Map<String, dynamic>;
      }
      return {};
    } on DioException catch (e) {
      debugPrint('Ошибка при получении статистики: ${e.message}');
      throw Exception('Не удалось получить статистику: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Отправить уведомление
  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    String type = 'info',
  }) async {
    try {
      final notificationData = {
        'title': title,
        'message': message,
        'type': type,
      };

      final response = await _dio.post(
        '$_notificationServiceUrl/api/notifications',
        data: notificationData,
      );

      debugPrint('Notification response status: ${response.statusCode}');
      debugPrint('Notification response data: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;
        if (responseData['success'] == true && responseData['data'] != null) {
          return responseData['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Не удалось отправить уведомление');
    } on DioException catch (e) {
      debugPrint('Ошибка при отправке уведомления: ${e.message}');
      throw Exception('Не удалось отправить уведомление: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Получить историю уведомлений
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    int limit = 50,
    int offset = 0,
    String? type,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (type != null) {
        queryParams['type'] = type;
      }
      if (isRead != null) {
        queryParams['isRead'] = isRead.toString();
      }

      final response = await _dio.get<Map<String, dynamic>>(
        '$_notificationServiceUrl/api/notifications/history',
        queryParameters: queryParams,
      );

      if (response.data != null && 
          response.data!['notifications'] is List) {
        return List<Map<String, dynamic>>.from(
          response.data!['notifications'] as List
        );
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Ошибка при получении уведомлений: ${e.message}');
      throw Exception('Не удалось получить уведомления: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }

  // Проверить здоровье сервисов
  Future<Map<String, bool>> checkServicesHealth() async {
    final results = <String, bool>{};
    
    try {
      await _dio.get<Map<String, dynamic>>('$_animalServiceUrl/health');
      results['animal_service'] = true;
    } on Exception {
      results['animal_service'] = false;
    }
    
    try {
      await _dio.get<Map<String, dynamic>>('$_notificationServiceUrl/health');
      results['notification_service'] = true;
    } on Exception {
      results['notification_service'] = false;
    }
    
    return results;
  }

  // Отметить уведомление как прочитанное
  Future<void> markNotificationAsRead(String id) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '$_notificationServiceUrl/api/notifications/$id/read',
      );

      if (response.data == null || response.data!['success'] != true) {
        throw Exception('Не удалось отметить уведомление как прочитанное');
      }
    } on DioException catch (e) {
      debugPrint('Ошибка при обновлении уведомления: ${e.message}');
      throw Exception('Не удалось обновить уведомление: ${e.message}');
    } on Exception catch (e) {
      debugPrint('Неожиданная ошибка: $e');
      throw Exception('Произошла неожиданная ошибка');
    }
  }
}