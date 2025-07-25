// lib/services/security_service.dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityService {
  // Hash sensitive data
  static String hashData(String data) {
    var bytes = utf8.encode(data);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+233\d{9}$').hasMatch(phone);
  }

  // Sanitize user input
  static String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'[<>]'), '')
        .replaceAll(RegExp(r'script', caseSensitive: false), '')
        .trim();
  }

  // Check password strength
  static bool isStrongPassword(String password) {
    return password.length >= 8 &&
           RegExp(r'[A-Z]').hasMatch(password) &&
           RegExp(r'[a-z]').hasMatch(password) &&
           RegExp(r'[0-9]').hasMatch(password);
  }
}