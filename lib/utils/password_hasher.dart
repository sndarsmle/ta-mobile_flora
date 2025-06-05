import 'dart:convert';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // data being hashed
    final digest = sha256.convert(bytes); // hash it using SHA256

    return digest.toString();
  }

  static bool verifyPassword(String plainPassword, String hashedPassword) {
    return hashPassword(plainPassword) == hashedPassword;
  }
}