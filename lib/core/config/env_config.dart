import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // API SUNAT Configuration - Using environment variables
  static String get personaId => 
    dotenv.env['PERSONA_ID'] ?? '683fbb3665e1970015000ce5';
  
  static String get personaToken => 
    dotenv.env['PERSONA_TOKEN'] ?? 'DEV_frjAanivPXw368Lf68MglksZXmxlrGdFPkuyt9uw7qkQwus0d0mX0wp4pvRKG1GB';
  
  static String get baseUrl => 
    dotenv.env['BASE_URL'] ?? 'https://back.apisunat.com';
  
  // Business Information - Default values (will be configurable via database in future)
  static String get rucEmisor => '10000000001';
  static String get registrationName => 'Vendify SAC';
  static String get partyName => 'Vendify';
  static String get address => 'DIRECCION_OPCIONAL';

  /// Initialize environment variables
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }

  /// Check if environment variables are properly loaded
  static bool get isLoaded => dotenv.isInitialized;

  /// Get all environment variables as a map for debugging (without sensitive data)
  static Map<String, String> get debugInfo => {
    'baseUrl': baseUrl,
    'rucEmisor': rucEmisor,
    'registrationName': registrationName,
    'partyName': partyName,
    'address': address,
    'personaId': personaId.isNotEmpty ? '***LOADED***' : '***NOT_LOADED***',
    'personaToken': personaToken.isNotEmpty ? '***LOADED***' : '***NOT_LOADED***',
  };

  /// Check if API credentials are properly configured
  static bool get isApiConfigured => 
    personaId.isNotEmpty && 
    personaToken.isNotEmpty && 
    baseUrl.isNotEmpty;

  /// Get API configuration status
  static Map<String, String> get apiConfigStatus => {
    'personaId': personaId.isNotEmpty ? '✅ Configured' : '❌ Missing',
    'personaToken': personaToken.isNotEmpty ? '✅ Configured' : '❌ Missing',
    'baseUrl': baseUrl.isNotEmpty ? '✅ Configured' : '❌ Missing',
  };
} 