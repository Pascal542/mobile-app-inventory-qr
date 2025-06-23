import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Configuración dinámica de Firebase
/// 
/// Este archivo maneja la configuración de Firebase de forma dinámica,
/// permitiendo diferentes configuraciones para diferentes entornos
/// (desarrollo, producción, testing).
class FirebaseConfig {
  /// Configuración de Firebase para Android
  static const FirebaseOptions _androidConfig = FirebaseOptions(
    apiKey: 'AIzaSyAyHIvodX2R4A438XJ9WV8BtlJgmAOhyL8',
    appId: '1:774381457370:android:3fbd2b3340e691c653fae3',
    messagingSenderId: '774381457370',
    projectId: 'vendify-qr',
    storageBucket: 'vendify-qr.firebasestorage.app',
  );

  /// Configuración de Firebase para iOS (placeholder)
  static const FirebaseOptions _iosConfig = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-messaging-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );

  /// Configuración de Firebase para Web (placeholder)
  static const FirebaseOptions _webConfig = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-messaging-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );

  /// Obtiene la configuración de Firebase para la plataforma actual
  /// 
  /// Retorna la configuración apropiada basada en la plataforma
  /// y el entorno de ejecución
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _getWebConfig();
    }
    
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _getAndroidConfig();
      case TargetPlatform.iOS:
        return _getIOSConfig();
      case TargetPlatform.macOS:
        return _getWebConfig(); // macOS usa configuración web
      case TargetPlatform.windows:
        return _getWebConfig(); // Windows usa configuración web
      case TargetPlatform.linux:
        return _getWebConfig(); // Linux usa configuración web
      default:
        throw UnsupportedError(
          'FirebaseConfig no está configurado para esta plataforma: $defaultTargetPlatform',
        );
    }
  }

  /// Obtiene la configuración de Android
  /// 
  /// Puede usar variables de entorno para configuraciones específicas
  static FirebaseOptions _getAndroidConfig() {
    // En el futuro, se pueden usar variables de entorno
    // final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? _androidConfig.apiKey;
    return _androidConfig;
  }

  /// Obtiene la configuración de iOS
  /// 
  /// Puede usar variables de entorno para configuraciones específicas
  static FirebaseOptions _getIOSConfig() {
    // En el futuro, se pueden usar variables de entorno
    // final apiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? _iosConfig.apiKey;
    return _iosConfig;
  }

  /// Obtiene la configuración de Web
  /// 
  /// Puede usar variables de entorno para configuraciones específicas
  static FirebaseOptions _getWebConfig() {
    // En el futuro, se pueden usar variables de entorno
    // final apiKey = dotenv.env['FIREBASE_WEB_API_KEY'] ?? _webConfig.apiKey;
    return _webConfig;
  }

  /// Inicializa Firebase con la configuración apropiada
  /// 
  /// [name] - Nombre de la aplicación (opcional)
  /// 
  /// Retorna una Future que se completa cuando Firebase está inicializado
  static Future<FirebaseApp> initializeApp({String? name}) async {
    try {
      return await Firebase.initializeApp(
        name: name,
        options: currentPlatform,
      );
    } catch (e) {
      throw FirebaseConfigException(
        'Error al inicializar Firebase: $e',
        platform: defaultTargetPlatform.toString(),
      );
    }
  }

  /// Verifica si Firebase está configurado correctamente
  /// 
  /// Retorna true si la configuración es válida
  static bool get isConfigured {
    try {
      final options = currentPlatform;
      return options.apiKey.isNotEmpty && 
             options.appId.isNotEmpty && 
             options.projectId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene información de configuración para debugging
  /// 
  /// Retorna un mapa con información de configuración (sin datos sensibles)
  static Map<String, dynamic> get debugInfo {
    try {
      final options = currentPlatform;
      return {
        'platform': defaultTargetPlatform.toString(),
        'projectId': options.projectId,
        'appId': options.appId,
        'messagingSenderId': options.messagingSenderId,
        'storageBucket': options.storageBucket,
        'apiKeyConfigured': options.apiKey.isNotEmpty,
        'isConfigured': isConfigured,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'isConfigured': false,
      };
    }
  }
}

/// Excepción personalizada para errores de configuración de Firebase
class FirebaseConfigException implements Exception {
  final String message;
  final String? platform;
  final String? operation;

  const FirebaseConfigException(
    this.message, {
    this.platform,
    this.operation,
  });

  @override
  String toString() {
    return 'FirebaseConfigException: $message${platform != null ? ' (Platform: $platform)' : ''}${operation != null ? ' (Operation: $operation)' : ''}';
  }
} 