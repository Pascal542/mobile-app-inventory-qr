# Guía de Desarrollo

## 🏗️ Arquitectura del Proyecto

### Clean Architecture

El proyecto sigue los principios de Clean Architecture con las siguientes capas:

#### 1. Presentation Layer
- **Páginas**: Widgets principales de la UI
- **BLoCs**: Gestión de estado y lógica de presentación
- **Widgets**: Componentes reutilizables

#### 2. Domain Layer
- **Entities**: Modelos de negocio
- **Use Cases**: Lógica de negocio
- **Repositories**: Interfaces para acceso a datos

#### 3. Data Layer
- **Models**: Modelos de datos con conversiones
- **Data Sources**: Fuentes de datos (API, Firestore, SQL)
- **Repositories**: Implementaciones de repositorios

### Patrones de Diseño

#### BLoC Pattern
```dart
// Eventos
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
}

class LoadProducts extends InventoryEvent {}

// Estados
abstract class InventoryState extends Equatable {
  const InventoryState();
}

class ProductsLoaded extends InventoryState {
  final List<Producto> products;
  const ProductsLoaded(this.products);
}

// BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  // Implementación
}
```

#### Dependency Injection con GetIt
```dart
// Registro de dependencias
GetIt.instance.registerSingleton<AuthService>(AuthService());
GetIt.instance.registerFactory<InventoryBloc>(() => InventoryBloc());

// Uso
final authService = GetIt.instance<AuthService>();
```

## 📝 Convenciones de Código

### Nomenclatura

#### Archivos
- **Páginas**: `nombre_page.dart` (ej: `login_page.dart`)
- **Widgets**: `nombre_widget.dart` (ej: `product_card.dart`)
- **BLoCs**: `nombre_bloc.dart` (ej: `inventory_bloc.dart`)
- **Modelos**: `nombre.dart` (ej: `producto.dart`)
- **Servicios**: `nombre_service.dart` (ej: `auth_service.dart`)

#### Clases
- **PascalCase**: `Producto`, `InventoryBloc`, `AuthService`
- **Eventos**: `LoadProducts`, `AddProduct`
- **Estados**: `ProductsLoaded`, `InventoryLoading`

#### Variables y Métodos
- **camelCase**: `productName`, `getProducts()`
- **Privados**: `_privateVariable`, `_privateMethod()`
- **Constantes**: `UPPER_SNAKE_CASE`

### Estructura de Archivos

```
lib/features/feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

## 🔧 Configuración del Entorno

### Flutter Doctor
```bash
flutter doctor -v
```

### Dependencias
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  go_router: ^12.1.3
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  http: ^1.1.0
  equatable: ^2.0.5
  flutter_dotenv: ^5.1.0
```

### Variables de Entorno
```env
# .env
SUNAT_API_URL=https://api.sunat.gob.pe
SUNAT_USERNAME=tu_usuario
SUNAT_PASSWORD=tu_password
```

## 🧪 Testing

### Estructura de Tests
```
test/
├── unit/
│   ├── models/
│   ├── services/
│   └── validators/
├── widget/
│   └── pages/
└── integration/
```

### Ejemplos de Tests

#### Unit Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Producto Model Tests', () {
    test('should create valid product from Firestore', () {
      // Arrange
      final mockDoc = MockDocumentSnapshot();
      when(mockDoc.id).thenReturn('test-id');
      when(mockDoc.data()).thenReturn({
        'nombre': 'Test Product',
        'cantidad': 10,
        'categoria': 'Test',
        'precio': 100.0,
      });

      // Act
      final producto = Producto.fromFirestore(mockDoc);

      // Assert
      expect(producto.id, 'test-id');
      expect(producto.nombre, 'Test Product');
      expect(producto.isValid, isTrue);
    });
  });
}
```

#### Widget Tests
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  testWidgets('should display products list', (WidgetTester tester) async {
    // Arrange
    final mockBloc = MockInventoryBloc();
    when(mockBloc.state).thenReturn(ProductsLoaded([
      Producto(nombre: 'Test', cantidad: 1, categoria: 'Test', precio: 100),
    ]));

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<InventoryBloc>.value(
          value: mockBloc,
          child: InventoryPage(),
        ),
      ),
    );

    // Assert
    expect(find.text('Test'), findsOneWidget);
  });
}
```

### Comandos de Testing
```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage

# Ejecutar tests específicos
flutter test test/unit/models/producto_test.dart

# Ejecutar tests de widgets
flutter test test/widget/
```

## 🔍 Análisis de Código

### Flutter Analyze
```bash
flutter analyze
```

### Reglas de Linting
```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_print
    - avoid_unused_constructor_parameters
    - await_only_futures
    - camel_case_types
    - cancel_subscriptions
    - constant_identifier_names
    - control_flow_in_finally
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - empty_statements
    - hash_and_equals
    - implementation_imports
    - library_names
    - library_prefixes
    - non_constant_identifier_names
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - prefer_const_constructors
    - prefer_final_fields
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_typing_uninitialized_variables
    - slash_for_doc_comments
    - test_types_in_equals
    - throw_in_finally
    - type_init_formals
    - unnecessary_brace_in_string_interps
    - unnecessary_getters_setters
    - unnecessary_new
    - unnecessary_null_aware_assignments
    - unnecessary_statements
    - unrelated_type_equality_checks
    - use_rethrow_when_possible
    - valid_regexps
```

## 🚀 Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build iOS
flutter build ios --release
```

### Firebase
```bash
# Deploy to Firebase
firebase deploy
```

## 📊 Monitoreo y Analytics

### Firebase Analytics
```dart
import 'package:firebase_analytics/firebase_analytics.dart';

// Eventos personalizados
await FirebaseAnalytics.instance.logEvent(
  name: 'product_added',
  parameters: {
    'product_name': productName,
    'category': category,
  },
);
```

### Crashlytics
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// Reportar errores
FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Error en operación de inventario',
);
```

## 🔒 Seguridad

### Validación de Entrada
```dart
// Validar datos de entrada
if (!FormValidators.email(email)) {
  throw ValidationException('Email inválido');
}

if (!FormValidators.ruc(ruc)) {
  throw ValidationException('RUC inválido');
}
```

### Manejo de Credenciales
```dart
// Usar variables de entorno
final apiUrl = EnvConfig.sunatApiUrl;
final username = EnvConfig.sunatUsername;
final password = EnvConfig.sunatPassword;
```

### Sanitización de Datos
```dart
// Sanitizar entrada de usuario
String sanitizeInput(String input) {
  return input.trim().replaceAll(RegExp(r'[<>"\']'), '');
}
```

## 📱 UI/UX Guidelines

### Material Design 3
- Usar componentes de Material 3
- Seguir las guías de diseño de Google
- Implementar temas dinámicos

### Responsive Design
```dart
// Adaptar a diferentes tamaños de pantalla
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return DesktopLayout();
    } else {
      return MobileLayout();
    }
  },
)
```

### Accessibility
```dart
// Agregar soporte para accesibilidad
Semantics(
  label: 'Botón para agregar producto',
  child: ElevatedButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
)
```

## 🔄 CI/CD

### GitHub Actions
```yaml
# .github/workflows/flutter.yml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.22.0'
    - run: flutter pub get
    - run: flutter test
    - run: flutter build apk
```

## 📚 Recursos Adicionales

### Documentación Oficial
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)

### Herramientas Útiles
- [Flutter Inspector](https://flutter.dev/docs/development/tools/flutter-inspector)
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Firebase Console](https://console.firebase.google.com)

### Comunidad
- [Flutter Community](https://flutter.dev/community)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev) 