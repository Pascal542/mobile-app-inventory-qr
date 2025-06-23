import 'package:flutter/foundation.dart';

/// Clase para manejar logging de forma apropiada
/// Solo muestra logs en modo debug, no en producción
class AppLogger {
  static const String _tag = '[Vendify]';

  /// Log de información (solo en debug)
  static void info(String message) {
    if (kDebugMode) {
      print('$_tag ℹ️ INFO: $message');
    }
  }

  /// Log de éxito (solo en debug)
  static void success(String message) {
    if (kDebugMode) {
      print('$_tag ✅ SUCCESS: $message');
    }
  }

  /// Log de advertencia (solo en debug)
  static void warning(String message) {
    if (kDebugMode) {
      print('$_tag ⚠️ WARNING: $message');
    }
  }

  /// Log de error (solo en debug)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_tag ❌ ERROR: $message');
      if (error != null) {
        print('$_tag 🔍 Error details: $error');
      }
      if (stackTrace != null) {
        print('$_tag 📍 Stack trace: $stackTrace');
      }
    }
  }

  /// Log de debug (solo en debug)
  static void debug(String message) {
    if (kDebugMode) {
      print('$_tag 🐛 DEBUG: $message');
    }
  }

  /// Log de operaciones de base de datos (solo en debug)
  static void database(String message) {
    if (kDebugMode) {
      print('$_tag 🗄️ DATABASE: $message');
    }
  }

  /// Log de operaciones de API (solo en debug)
  static void api(String message) {
    if (kDebugMode) {
      print('$_tag 🌐 API: $message');
    }
  }

  /// Log de autenticación (solo en debug)
  static void auth(String message) {
    if (kDebugMode) {
      print('$_tag 🔐 AUTH: $message');
    }
  }

  /// Log de navegación (solo en debug)
  static void navigation(String message) {
    if (kDebugMode) {
      print('$_tag 🧭 NAVIGATION: $message');
    }
  }
} 