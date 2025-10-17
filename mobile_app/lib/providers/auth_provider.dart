import 'package:flutter/foundation.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  String? _userId;
  String? _userEmail;
  String? _userName;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;
  String? get userId => _userId;
  String? get userEmail => _userEmail;
  String? get userName => _userName;

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Имитация аутентификации (для демо)
      await Future<void>.delayed(const Duration(seconds: 1));
      
      // Простая проверка для демо
      if (email.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _userId = 'demo_user_id';
        _userEmail = email;
        _userName = email.split('@').first;
        return true;
      } else {
        _error = 'Неверные учетные данные';
        return false;
      }
    } on Exception catch (e) {
      _error = 'Ошибка входа: ${e.toString()}';
      debugPrint('Error signing in: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Имитация регистрации (для демо)
      await Future<void>.delayed(const Duration(seconds: 1));
      
      if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
        _isAuthenticated = true;
        _userId = 'demo_user_id';
        _userEmail = email;
        _userName = name;
        return true;
      } else {
        _error = 'Некорректные данные для регистрации';
        return false;
      }
    } on Exception catch (e) {
      _error = 'Ошибка регистрации: ${e.toString()}';
      debugPrint('Error signing up: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 500));
      
      _isAuthenticated = false;
      _userId = null;
      _userEmail = null;
      _userName = null;
      _error = null;
    } on Exception catch (e) {
      _error = 'Ошибка выхода: ${e.toString()}';
      debugPrint('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Проверка сохраненной сессии (для демо всегда false)
  Future<void> checkAuthStatus() async {
    _isAuthenticated = false;
    notifyListeners();
  }

  // Сброс пароля (для демо)
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future<void>.delayed(const Duration(seconds: 1));
      
      if (email.isNotEmpty && email.contains('@')) {
        return true;
      } else {
        _error = 'Некорректный email адрес';
        return false;
      }
    } on Exception catch (e) {
      _error = 'Ошибка сброса пароля: ${e.toString()}';
      debugPrint('Error resetting password: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Обновление профиля пользователя
  Future<bool> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 800));
      
      if (name != null && name.isNotEmpty) {
        _userName = name;
      }
      if (email != null && email.isNotEmpty && email.contains('@')) {
        _userEmail = email;
      }
      
      return true;
    } on Exception catch (e) {
      _error = 'Ошибка обновления профиля: ${e.toString()}';
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}