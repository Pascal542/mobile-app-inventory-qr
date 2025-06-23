# Configuración de Firebase

## 📋 Descripción

Este proyecto utiliza una configuración dinámica de Firebase que permite manejar diferentes entornos (desarrollo, producción, testing) de forma flexible y segura.

## 🏗️ Arquitectura

### FirebaseConfig Class

La clase `FirebaseConfig` en `lib/core/config/firebase_config.dart` maneja toda la configuración de Firebase de forma dinámica.

#### Características:
- **Configuración por plataforma**: Diferentes configuraciones para Android, iOS y Web
- **Manejo de errores**: Excepciones personalizadas para problemas de configuración
- **Validación**: Verificación automática de configuración válida
- **Debugging**: Información de configuración para debugging
- **Flexibilidad**: Preparado para usar variables de entorno en el futuro

## 🔧 Configuración Actual

### Android
```dart
static const FirebaseOptions _androidConfig = FirebaseOptions(
  apiKey: 'AIzaSyAyHIvodX2R4A438XJ9WV8BtlJgmAOhyL8',
  appId: '1:774381457370:android:3fbd2b3340e691c653fae3',
  messagingSenderId: '774381457370',
  projectId: 'vendify-qr',
  storageBucket: 'vendify-qr.firebasestorage.app',
);
```

### iOS (Placeholder)
```dart
static const FirebaseOptions _iosConfig = FirebaseOptions(
  apiKey: 'your-ios-api-key',
  appId: 'your-ios-app-id',
  messagingSenderId: 'your-messaging-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-storage-bucket',
);
```

### Web (Placeholder)
```dart
static const FirebaseOptions _webConfig = FirebaseOptions(
  apiKey: 'your-web-api-key',
  appId: 'your-web-app-id',
  messagingSenderId: 'your-messaging-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-storage-bucket',
);
```

## 🚀 Uso

### Inicialización Automática

Firebase se inicializa automáticamente en `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with dynamic configuration
  try {
    await FirebaseConfig.initializeApp();
    AppLogger.success("Firebase initialized successfully");
    
    // Log Firebase configuration info for debugging
    final firebaseInfo = FirebaseConfig.debugInfo;
    AppLogger.info("Firebase configuration: $firebaseInfo");
  } catch (e) {
    AppLogger.error("Error initializing Firebase", e);
    // Continue app execution even if Firebase fails
  }
  
  runApp(const MyApp());
}
```

### Verificación de Configuración

```dart
// Verificar si Firebase está configurado
if (FirebaseConfig.isConfigured) {
  print("Firebase está configurado correctamente");
} else {
  print("Firebase no está configurado");
}

// Obtener información de debugging
final debugInfo = FirebaseConfig.debugInfo;
print("Debug info: $debugInfo");
```

## 🔒 Seguridad

### Configuración Hardcodeada vs Variables de Entorno

**Estado Actual**: La configuración está hardcodeada en el código, pero la arquitectura está preparada para usar variables de entorno.

**Plan Futuro**: Implementar variables de entorno para mayor seguridad:

```dart
// Ejemplo futuro con variables de entorno
static FirebaseOptions _getAndroidConfig() {
  final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? _androidConfig.apiKey;
  final appId = dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? _androidConfig.appId;
  
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    // ... otros campos
  );
}
```

### Variables de Entorno Recomendadas

```env
# Firebase Configuration
FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_ANDROID_APP_ID=your-android-app-id
FIREBASE_ANDROID_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_ANDROID_PROJECT_ID=your-project-id
FIREBASE_ANDROID_STORAGE_BUCKET=your-storage-bucket

FIREBASE_IOS_API_KEY=your-ios-api-key
FIREBASE_IOS_APP_ID=your-ios-app-id
FIREBASE_IOS_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_IOS_PROJECT_ID=your-project-id
FIREBASE_IOS_STORAGE_BUCKET=your-storage-bucket

FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_WEB_APP_ID=your-web-app-id
FIREBASE_WEB_MESSAGING_SENDER_ID=your-messaging-sender-id
FIREBASE_WEB_PROJECT_ID=your-project-id
FIREBASE_WEB_STORAGE_BUCKET=your-storage-bucket
```

## 🧪 Testing

### Configuración para Testing

Para testing, se puede usar una configuración específica:

```dart
// En tests
class TestFirebaseConfig extends FirebaseConfig {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'test-api-key',
      appId: 'test-app-id',
      messagingSenderId: 'test-sender-id',
      projectId: 'test-project',
      storageBucket: 'test-bucket',
    );
  }
}
```

### Mocking Firebase

```dart
// Ejemplo de test con Firebase mockeado
testWidgets('should initialize Firebase correctly', (WidgetTester tester) async {
  // Arrange
  when(FirebaseConfig.initializeApp()).thenAnswer((_) async => MockFirebaseApp());
  
  // Act
  await main();
  
  // Assert
  verify(FirebaseConfig.initializeApp()).called(1);
});
```

## 🔄 Migración desde firebase_options.dart

### Antes (Hardcodeado)
```dart
import 'firebase_options.dart';

await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

### Después (Dinámico)
```dart
import 'core/config/firebase_config.dart';

await FirebaseConfig.initializeApp();
```

## 📱 Configuración por Plataforma

### Android
1. Descargar `google-services.json` desde Firebase Console
2. Colocar en `android/app/google-services.json`
3. Configurar en `android/build.gradle` y `android/app/build.gradle`

### iOS
1. Descargar `GoogleService-Info.plist` desde Firebase Console
2. Colocar en `ios/Runner/GoogleService-Info.plist`
3. Agregar a Xcode project

### Web
1. Configurar en Firebase Console
2. Obtener configuración para web
3. Actualizar en `FirebaseConfig._webConfig`

## 🐛 Troubleshooting

### Error: "FirebaseConfig no está configurado para esta plataforma"
**Causa**: La plataforma no está soportada o no está configurada.
**Solución**: Agregar configuración para la plataforma en `FirebaseConfig`.

### Error: "Error al inicializar Firebase"
**Causa**: Configuración inválida o problemas de red.
**Solución**: 
1. Verificar configuración en Firebase Console
2. Verificar conectividad de red
3. Revisar logs de Firebase

### Error: "API Key inválida"
**Causa**: API Key incorrecta o expirada.
**Solución**: 
1. Regenerar API Key en Firebase Console
2. Actualizar configuración
3. Verificar restricciones de API Key

## 📊 Monitoreo

### Logs de Configuración

La aplicación registra información de configuración en modo debug:

```dart
AppLogger.info("Firebase configuration: ${FirebaseConfig.debugInfo}");
```

### Métricas Recomendadas

- Tiempo de inicialización de Firebase
- Tasa de éxito de inicialización
- Errores de configuración por plataforma
- Uso de servicios de Firebase

## 🔮 Roadmap

### Fase 1: Variables de Entorno ✅
- [x] Arquitectura preparada para variables de entorno
- [ ] Implementar variables de entorno para todas las plataformas
- [ ] Documentación de variables requeridas

### Fase 2: Configuración Dinámica
- [ ] Configuración por entorno (dev, staging, prod)
- [ ] Configuración remota con Firebase Remote Config
- [ ] Rotación automática de API Keys

### Fase 3: Monitoreo Avanzado
- [ ] Métricas de rendimiento de Firebase
- [ ] Alertas automáticas para problemas de configuración
- [ ] Dashboard de estado de Firebase

## 📚 Recursos

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase CLI](https://firebase.google.com/docs/cli) 