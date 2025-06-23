import 'package:flutter/material.dart';

class AppSnackbar {
  static void success(BuildContext context, String message) {
    _show(context, message, Colors.green.shade600);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, Colors.red.shade600);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, Colors.blue.shade600);
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
} 