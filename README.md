# Mobile App Inventory QR

Aplicación móvil Flutter para gestión de inventario y emisión de documentos electrónicos (facturas y boletas) integrada con la API de SUNAT.

## 🚀 Características

### 📱 Funcionalidades Principales
- **Gestión de Inventario**: Agregar, modificar, eliminar y listar productos
- **Emisión de Documentos**: Generar facturas y boletas electrónicas
- **Integración SUNAT**: Conexión directa con la API de SUNAT para documentos electrónicos
- **Sistema de Autenticación**: Login y registro de usuarios con Firebase Auth
- **Generación de QR**: Códigos QR para productos y documentos
- **Reportes**: Generación de reportes de ventas e inventario
- **Escaneo de Códigos**: Lector de códigos QR y códigos de barras

### 🏗️ Arquitectura
- **Clean Architecture**: Separación clara de capas (presentation, domain, data)
- **BLoC Pattern**: Gestión de estado con flutter_bloc
- **Dependency Injection**: Inyección de dependencias con GetIt
- **GoRouter**: Navegación declarativa y tipada
- **Firebase**: Autenticación y base de datos en la nube

## 📋 Requisitos Previos

- Flutter 3.x o superior
- Dart 3.x o superior
- Firebase project configurado
- Credenciales de la API SUNAT

## 🛠️ Instalación

1. **Clonar el repositorio**
   ```bash
   git clone <repository-url>
   cd mobile-app-inventory-qr
   ```

2. **Instalar dependencias**
   ```bash
   flutter pub get
   ```

3. **Configurar variables de entorno**
   ```bash
   cp .env.example .env
   ```
   
   Editar `.env` con tus credenciales:
   ```env
   SUNAT_API_URL=https://api.sunat.gob.pe
   SUNAT_USERNAME=tu_usuario
   SUNAT_PASSWORD=tu_password
   ```

4. **Configurar Firebase**
   - Agregar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
   - Configurar Firebase Auth y Firestore

5. **Ejecutar la aplicación**
   ```bash
   flutter run
   ```

## 📁 Estructura del Proyecto

```
lib/
├── core/                           # Funcionalidades core
│   ├── config/                     # Configuración de la app
│   ├── data/                       # Datos core (SQL, Auth)
│   ├── di/                         # Inyección de dependencias
│   ├── theme/                      # Temas y estilos
│   ├── utils/                      # Utilidades (Logger, SnackBar)
│   ├── validation/                 # Validaciones centralizadas
│   └── widgets/                    # Widgets reutilizables
├── features/                       # Características de la app
│   ├── auth/                       # Autenticación
│   ├── inventory/                  # Gestión de inventario
│   ├── menu/                       # Menú principal
│   ├── qr/                         # Generación y escaneo de QR
│   ├── reports/                    # Reportes
│   └── sales/                      # Ventas y documentos
└── main.dart                       # Punto de entrada
```

## 🔧 Configuración

### Variables de Entorno
El proyecto utiliza variables de entorno para configuraciones sensibles:

- `SUNAT_API_URL`: URL base de la API de SUNAT
- `SUNAT_USERNAME`: Usuario de la API de SUNAT
- `SUNAT_PASSWORD`: Contraseña de la API de SUNAT

### Firebase
Configurar Firebase Auth y Firestore para:
- Autenticación de usuarios
- Almacenamiento de productos
- Historial de documentos

## 📱 Uso

### Autenticación
1. Registrarse con email y contraseña
2. Iniciar sesión con las credenciales creadas

### Gestión de Inventario
1. Ir a "Inventario" en el menú principal
2. Agregar productos con nombre, cantidad, categoría y precio
3. Modificar o eliminar productos existentes
4. Ver listado de todos los productos

### Emisión de Documentos
1. Ir a "Ventas" en el menú principal
2. Seleccionar tipo de documento (Factura o Boleta)
3. Completar datos del cliente y productos
4. Generar documento electrónico
5. Ver estado del documento en SUNAT

### Reportes
1. Ir a "Reportes" en el menú principal
2. Seleccionar tipo de reporte
3. Configurar filtros de fecha
4. Generar y visualizar reporte

## 🧪 Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/features/inventory/

# Ejecutar tests con coverage
flutter test --coverage
```

## 📦 Dependencias Principales

- **flutter_bloc**: Gestión de estado
- **get_it**: Inyección de dependencias
- **go_router**: Navegación
- **firebase_auth**: Autenticación
- **cloud_firestore**: Base de datos
- **qr_flutter**: Generación de QR
- **qr_code_scanner**: Escaneo de QR
- **http**: Cliente HTTP para APIs
- **equatable**: Comparación de objetos

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

Para soporte técnico o preguntas:
- Crear un issue en GitHub
- Contactar al equipo de desarrollo

## 🔄 Changelog

### v1.0.0
- Implementación inicial
- Gestión básica de inventario
- Emisión de documentos electrónicos
- Sistema de autenticación
- Generación y escaneo de QR
- Reportes básicos

---

**Desarrollado con ❤️ usando Flutter**
