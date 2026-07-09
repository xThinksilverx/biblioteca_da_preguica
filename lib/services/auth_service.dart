import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'database_service.dart';

class AuthService {
  static const String _userIdKey = 'logged_user_id';

  static AuthService? _instance;
  AuthService._();

  static AuthService get instance {
    _instance ??= AuthService._();
    return _instance!;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<User?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final existingEmail = await DatabaseService.instance.getUserByEmail(email);
    if (existingEmail != null) {
      throw Exception('Email ja cadastrado');
    }

    final existingUsername =
        await DatabaseService.instance.getUserByUsername(username);
    if (existingUsername != null) {
      throw Exception('Nome de usuario ja em uso');
    }

    final user = User(
      username: username,
      email: email,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    final id = await DatabaseService.instance.insertUser(user);
    final created = User(
      id: id,
      username: user.username,
      email: user.email,
      passwordHash: user.passwordHash,
      createdAt: user.createdAt,
    );

    await _saveSession(id);
    return created;
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final user = await DatabaseService.instance.getUserByEmail(email);
    if (user == null) {
      throw Exception('Usuario nao encontrado');
    }

    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Senha incorreta');
    }

    await _saveSession(user.id!);
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
  }

  Future<User?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (userId == null) return null;
    return await DatabaseService.instance.getUserById(userId);
  }

  Future<bool> isLoggedIn() async {
    final user = await getLoggedUser();
    return user != null;
  }

  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }
}
