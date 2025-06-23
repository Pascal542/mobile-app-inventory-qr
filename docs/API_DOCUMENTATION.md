# Documentación de API

## API de SUNAT

### Configuración

La aplicación se integra con la API de SUNAT para la emisión de documentos electrónicos (facturas y boletas).

#### Variables de Entorno Requeridas

```env
SUNAT_API_URL=https://api.sunat.gob.pe
SUNAT_USERNAME=tu_usuario_sunat
SUNAT_PASSWORD=tu_password_sunat
```

### Endpoints Principales

#### 1. Emisión de Documentos

**POST** `/api/v1/documents`

Emite un documento electrónico (factura o boleta).

**Parámetros:**
```json
{
  "documentType": "01", // 01: Factura, 03: Boleta
  "customer": {
    "ruc": "12345678901",
    "name": "Cliente Ejemplo",
    "address": "Dirección del Cliente"
  },
  "items": [
    {
      "description": "Producto 1",
      "quantity": 2,
      "unitPrice": 100.00,
      "total": 200.00
    }
  ],
  "total": 200.00
}
```

**Respuesta:**
```json
{
  "success": true,
  "documentId": "F001-00000001",
  "status": "accepted",
  "xml": "<?xml version=\"1.0\"...",
  "cdr": "<?xml version=\"1.0\"..."
}
```

#### 2. Consulta de Estado

**GET** `/api/v1/documents/{documentId}`

Consulta el estado de un documento emitido.

**Respuesta:**
```json
{
  "documentId": "F001-00000001",
  "status": "accepted",
  "fileName": "F001-00000001.xml",
  "issueTime": 1640995200,
  "total": 200.00
}
```

### Códigos de Estado

- `accepted`: Documento aceptado por SUNAT
- `rejected`: Documento rechazado por SUNAT
- `pending`: Documento en proceso de validación

## Servicios Internos

### AuthService

Servicio para manejar la autenticación de usuarios.

#### Métodos

```dart
/// Inicia sesión con email y contraseña
Future<UserCredential> signIn({
  required String email,
  required String password,
});

/// Crea una nueva cuenta de usuario
Future<UserCredential> createAccount({
  required String email,
  required String password,
});

/// Obtiene el usuario actual
User? get currentUser;

/// Stream de cambios en el estado de autenticación
Stream<User?> get authStateChanges;
```

### FirestoreService

Servicio para interactuar con Firestore (base de datos en la nube).

#### Métodos

```dart
/// Agrega un producto a Firestore
Future<String> agregarProducto(
  String nombre,
  int cantidad,
  String categoria,
  double precio,
);

/// Obtiene todos los productos
Stream<List<Producto>> obtenerProductos();

/// Actualiza un producto por nombre
Future<void> actualizarProductoPorNombre(
  String nombre,
  String nuevoNombre,
  int nuevaCantidad,
  double nuevoPrecio,
  String nuevaCategoria,
);

/// Elimina un producto por ID
Future<void> eliminarProducto(String id);
```

### SalesApiService

Servicio para interactuar con la API de SUNAT.

#### Métodos

```dart
/// Emite un documento electrónico
Future<SalesDocument> emitirDocumento({
  required String tipoDocumento,
  required Map<String, dynamic> datosCliente,
  required List<Map<String, dynamic>> items,
  required double total,
});

/// Consulta el estado de un documento
Future<SalesDocument> consultarEstadoDocumento(String documentId);

/// Obtiene el último número de documento
Future<int> obtenerUltimoNumeroDocumento(String tipoDocumento);
```

## Modelos de Datos

### Producto

```dart
class Producto {
  final String? id;
  final String nombre;
  final int cantidad;
  final String categoria;
  final double precio;
  
  // Métodos de conversión
  factory Producto.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toMap();
  Producto copyWith({...});
  
  // Validaciones
  bool get isValid;
  String get summary;
}
```

### SalesDocument

```dart
class SalesDocument {
  final String documentId;
  final String fileName;
  final String status;
  final String type;
  final int issueTime;
  final String? xml;
  final String? cdr;
  final String? customerRuc;
  final String? customerName;
  final double? total;
  
  // Métodos de conversión
  factory SalesDocument.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  SalesDocument copyWith({...});
  
  // Formateo
  String get statusFormatted;
  String get typeFormatted;
  String get totalFormatted;
  String get dateFormatted;
}
```

## Manejo de Errores

### Excepciones Personalizadas

```dart
/// Excepción para errores de autenticación
class AuthException implements Exception {
  final String message;
  final String? code;
  
  const AuthException(this.message, [this.code]);
}

/// Excepción para errores de Firestore
class FirestoreException implements Exception {
  final String message;
  final String? operation;
  
  const FirestoreException(this.message, [this.operation]);
}

/// Excepción para errores de la API de SUNAT
class SunatApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? documentId;
  
  const SunatApiException(this.message, [this.statusCode, this.documentId]);
}
```

### Códigos de Error Comunes

#### Autenticación
- `user-not-found`: Usuario no encontrado
- `wrong-password`: Contraseña incorrecta
- `email-already-in-use`: Email ya está en uso
- `weak-password`: Contraseña muy débil

#### Firestore
- `permission-denied`: Sin permisos para acceder
- `not-found`: Documento no encontrado
- `already-exists`: Documento ya existe

#### API SUNAT
- `400`: Datos del documento inválidos
- `401`: Credenciales incorrectas
- `403`: Sin permisos para emitir documentos
- `500`: Error interno del servidor

## Logging

La aplicación utiliza un sistema de logging centralizado que solo muestra logs en modo debug:

```dart
/// Log de información
AppLogger.info('Mensaje informativo');

/// Log de éxito
AppLogger.success('Operación exitosa');

/// Log de advertencia
AppLogger.warning('Advertencia');

/// Log de error
AppLogger.error('Error ocurrido', error);

/// Log específico para operaciones de base de datos
AppLogger.db('Operación de base de datos');

/// Log específico para operaciones de API
AppLogger.api('Llamada a API');
```

## Validaciones

### Validadores de Formularios

```dart
/// Validar campo requerido
FormValidators.required('Campo requerido');

/// Validar email
FormValidators.email('Email inválido');

/// Validar DNI (8 dígitos)
FormValidators.dni('DNI inválido');

/// Validar RUC (11 dígitos)
FormValidators.ruc('RUC inválido');

/// Validar contraseña
FormValidators.password('Contraseña inválida');

/// Validar cantidad (número entero positivo)
FormValidators.quantity('Cantidad inválida');

/// Validar precio (número decimal positivo)
FormValidators.price('Precio inválido');
```

## Configuración de Dependencias

### GetIt (Dependency Injection)

```dart
/// Registrar servicios
GetIt.instance.registerSingleton<AuthService>(AuthService());
GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
GetIt.instance.registerSingleton<SalesApiService>(SalesApiService());

/// Registrar BLoCs
GetIt.instance.registerFactory<InventoryBloc>(() => InventoryBloc(
  firestoreService: GetIt.instance<FirestoreService>(),
));

/// Obtener dependencias
final authService = GetIt.instance<AuthService>();
final inventoryBloc = GetIt.instance<InventoryBloc>();
```

## Testing

### Ejemplos de Tests

```dart
/// Test de validación de producto
test('Producto válido debe pasar validación', () {
  final producto = Producto(
    nombre: 'Producto Test',
    cantidad: 10,
    categoria: 'Electrónicos',
    precio: 100.0,
  );
  
  expect(producto.isValid, isTrue);
});

/// Test de conversión JSON
test('SalesDocument debe convertir correctamente desde JSON', () {
  final json = {
    'documentId': 'F001-00000001',
    'fileName': 'F001-00000001.xml',
    'status': 'accepted',
    'type': '01',
    'issueTime': 1640995200,
  };
  
  final document = SalesDocument.fromJson(json);
  
  expect(document.documentId, 'F001-00000001');
  expect(document.status, 'accepted');
  expect(document.typeFormatted, 'Factura');
});
``` 