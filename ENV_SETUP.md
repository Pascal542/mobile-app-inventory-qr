# Configuración de Variables de Entorno

## 📋 Descripción

Este proyecto utiliza variables de entorno para manejar credenciales sensibles de la API SUNAT de forma segura. La información del negocio se manejará desde la base de datos en futuras implementaciones.

## 🔧 Configuración

### 1. Crear archivo `.env`

Crea un archivo `.env` en la raíz del proyecto con el siguiente contenido:

```env
# API SUNAT Credentials
PERSONA_ID=tu_persona_id_aqui
PERSONA_TOKEN=tu_persona_token_aqui
BASE_URL=https://back.apisunat.com
```

### 2. Obtener Credenciales SUNAT

Para obtener las credenciales de la API SUNAT:

1. Regístrate en [API SUNAT](https://apisunat.com)
2. Crea una nueva aplicación
3. Obtén tu `PERSONA_ID` y `PERSONA_TOKEN`
4. Usa la URL base proporcionada por la API

### 3. Información del Negocio

**Nota**: La información del negocio (RUC, nombre, dirección) se manejará desde la base de datos en futuras implementaciones. Por ahora, se usan valores por defecto para desarrollo.

## 🔒 Seguridad

### ✅ Buenas Prácticas

- ✅ **Nunca** subas el archivo `.env` al repositorio
- ✅ **Siempre** usa `.env.example` como plantilla
- ✅ **Verifica** que `.env` esté en `.gitignore`
- ✅ **Usa** valores por defecto para desarrollo

### ❌ Lo que NO hacer

- ❌ No hardcodear credenciales en el código
- ❌ No compartir tokens en repositorios públicos
- ❌ No usar credenciales de producción en desarrollo

## 🚀 Uso en el Código

```dart
import 'package:mobile_app_inventory_qr/core/config/env_config.dart';

// Obtener valores de API
String personaId = EnvConfig.personaId;
String token = EnvConfig.personaToken;
String baseUrl = EnvConfig.baseUrl;

// Verificar si están cargadas
if (EnvConfig.isLoaded) {
  print('✅ Variables de entorno cargadas');
}

// Verificar configuración de API
if (EnvConfig.isApiConfigured) {
  print('✅ API SUNAT configurada correctamente');
}

// Debug info (sin datos sensibles)
print(EnvConfig.debugInfo);
print(EnvConfig.apiConfigStatus);
```

## 🐛 Troubleshooting

### Error: "Could not load .env file"

1. Verifica que el archivo `.env` existe en la raíz
2. Verifica que está incluido en `pubspec.yaml` como asset
3. Verifica la sintaxis del archivo (sin espacios alrededor del `=`)

### Error: "Environment variables not loaded"

1. Verifica que `flutter_dotenv` está en las dependencias
2. Verifica que `EnvConfig.load()` se llama en `main()`
3. Verifica que el archivo `.env` tiene el formato correcto

### Error: "API not configured"

1. Verifica que `PERSONA_ID` y `PERSONA_TOKEN` están en el archivo `.env`
2. Verifica que los valores no están vacíos
3. Verifica que `EnvConfig.isApiConfigured` es `true`

## 📝 Ejemplo de Archivo .env

```env
# API SUNAT Credentials
PERSONA_ID=683fbb3665e1970015000ce5
PERSONA_TOKEN=DEV_frjAanivPXw368Lf68MglksZXmxlrGdFPkuyt9uw7qkQwus0d0mX0wp4pvRKG1GB
BASE_URL=https://back.apisunat.com
```

## 🔄 Migración

Si ya tienes credenciales hardcodeadas:

1. Crea el archivo `.env` con tus credenciales actuales
2. El código automáticamente usará las variables de entorno
3. Si no encuentra el archivo `.env`, usará valores por defecto
4. Elimina las credenciales hardcodeadas del código

## 🔮 Futuras Implementaciones

### Base de Datos para Información del Negocio

En futuras versiones, la información del negocio se cargará desde la base de datos:

- **RUC_EMISOR**: Se cargará desde la configuración del usuario
- **REGISTRATION_NAME**: Nombre legal desde la base de datos
- **PARTY_NAME**: Nombre comercial desde la base de datos  
- **ADDRESS**: Dirección fiscal desde la base de datos

### Configuración Dinámica

- Interfaz de usuario para configurar información del negocio
- Persistencia en base de datos local o remota
- Validación de datos empresariales
- Múltiples configuraciones por usuario

## 📞 Soporte

Si tienes problemas con la configuración:

1. Verifica que sigues todos los pasos
2. Revisa los logs de la aplicación
3. Verifica que `EnvConfig.isLoaded` es `true`
4. Verifica que `EnvConfig.isApiConfigured` es `true`
5. Contacta al equipo de desarrollo 