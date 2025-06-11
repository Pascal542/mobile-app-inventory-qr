# Mobile App Inventory QR

Aplicación móvil para gestión de inventario usando códigos QR, desarrollada con Flutter.

## Requisitos

- Flutter 3.22.0 o superior
- Dart 3.4.0 o superior
- Android Studio / VS Code
- Git

## Configuración del Entorno

1. Instala Flutter siguiendo la [guía oficial](https://flutter.dev/docs/get-started/install)
2. Verifica la instalación:
```bash
flutter doctor
```

## Ejecutar el Proyecto

1. Clona el repositorio:
```bash
git clone https://github.com/your-username/mobile-app-inventory-qr.git
cd mobile-app-inventory-qr
```

2. Instala las dependencias:
```bash
flutter pub get
```

3. Ejecuta la aplicación:
```bash
flutter run
```

## Estructura del Proyecto

```
lib/
  ├── core/           # Funcionalidades core y utilidades
  ├── features/       # Módulos de la aplicación
  │   ├── auth/       # Autenticación
  │   ├── home/       # Página principal
  │   ├── qr/         # Funcionalidad QR
  │   ├── reports/    # Reportes
  │   ├── sales/      # Ventas
  │   └── payment/    # Pagos
  ├── l10n/          # Archivos de localización
  └── main.dart      # Punto de entrada
```

## Características

- Autenticación de usuarios
- Escaneo de códigos QR
- Gestión de inventario
- Reportes y estadísticas
- Sistema de pagos
- Gestión de ventas

## Tecnologías Utilizadas

- Flutter
- Dart
- GoRouter para navegación
- BLoC para gestión de estado
