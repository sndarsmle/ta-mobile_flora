import 'package:flutter/material.dart';
import 'package:projekakhir_praktpm/models/user_model.dart';
import 'package:projekakhir_praktpm/services/hive_service.dart';
import 'package:projekakhir_praktpm/utils/password_hasher.dart';
import 'package:uuid/uuid.dart';

class UserPresenter extends ChangeNotifier {
  UserPresenter();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<void> register(User user) async {
    try {
      await HiveService().init();
      final users = await HiveService().getAllRegisteredUsers();

      if (users.any((u) => u.username == user.username || u.email == user.email)) {
        throw Exception('Username or email already exists.');
      }

      final hashedPassword = PasswordHasher.hashPassword(user.password);
      final newUser = User(
        id: const Uuid().v4(),
        username: user.username,
        email: user.email,
        password: hashedPassword,
      );

      await HiveService().saveRegisteredUser(newUser);
      await HiveService().saveUser(newUser);
      _currentUser = newUser;
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      await HiveService().init();
      final users = await HiveService().getAllRegisteredUsers();

      User? foundUser;
      for (var user in users) {
        if (user.email == email && PasswordHasher.verifyPassword(password, user.password)) {
          foundUser = user;
          break;
        }
      }

      if (foundUser != null) {
        await HiveService().saveUser(foundUser);
        await HiveService().saveSession(const Uuid().v4(), DateTime.now().add(const Duration(hours: 1)));
        _currentUser = foundUser;
        notifyListeners();
        return foundUser;
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Login failed: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> logout() async {
    try {
      await HiveService().logout();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<User?> getLoggedInUser() async {
    try {
      await HiveService().init();
      final user = await HiveService().getCurrentUser();
      final sessionToken = await HiveService().getSessionToken();
      final sessionExpiry = await HiveService().getSessionExpiryTime();

      if (user != null && sessionToken != null && sessionExpiry != null && sessionExpiry.isAfter(DateTime.now())) {
        _currentUser = user;
      } else {
        await HiveService().logout();
        _currentUser = null;
      }
      return _currentUser;
    } catch (e) {
      debugPrint('Error getting logged in user: $e');
      return null;
    }
  }

  void setCurrentUser(User? user) {
        _currentUser = user;
  }
}