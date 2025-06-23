import 'package:mobile_app_inventory_qr/core/config/env_config.dart';

class ApiConstants {
  // API SUNAT Configuration - Now using environment variables
  static String get personaId => EnvConfig.personaId;
  static String get personaToken => EnvConfig.personaToken;
  static String get baseUrl => EnvConfig.baseUrl;
  
  // Business Information - Now using environment variables
  static String get rucEmisor => EnvConfig.rucEmisor;
  static String get registrationName => EnvConfig.registrationName;
  static String get partyName => EnvConfig.partyName;
  static String get address => EnvConfig.address;

  /// Check if environment variables are properly loaded
  static bool get isConfigured => EnvConfig.isLoaded;

  /// Get configuration status for debugging
  static Map<String, String> get configStatus => EnvConfig.debugInfo;
}
