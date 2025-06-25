# Formulario de Feedback - Vendify

## Propósito
Este documento contiene las preguntas sugeridas para el formulario de Google Forms que se abrirá cuando los usuarios presionen el botón "Feedback" en la aplicación.

## URL del Formulario
**IMPORTANTE**: Reemplazar `EXAMPLE_FORM_ID` en `lib/features/sales/presentation/pages/home_page.dart` con el ID real del formulario de Google Forms.

## Preguntas Sugeridas

### 1. Información General
- **Pregunta**: ¿Qué te parece la aplicación Vendify en general?
  - **Tipo**: Escala de 1-5 estrellas
  - **Opciones**: 1 (Muy mala) a 5 (Excelente)

### 2. Funcionalidades
- **Pregunta**: ¿Qué funcionalidad usas más frecuentemente?
  - **Tipo**: Opción múltiple
  - **Opciones**: 
    - Ventas (Boletas/Facturas)
    - Inventario
    - Escáner QR
    - Reportes
    - Referidos

### 3. Experiencia de Usuario
- **Pregunta**: ¿Qué tan fácil es navegar por la aplicación?
  - **Tipo**: Escala de 1-5
  - **Opciones**: 1 (Muy difícil) a 5 (Muy fácil)

- **Pregunta**: ¿La interfaz es intuitiva y fácil de usar?
  - **Tipo**: Escala de 1-5
  - **Opciones**: 1 (No es intuitiva) a 5 (Muy intuitiva)

### 4. Rendimiento
- **Pregunta**: ¿Qué tan rápido responde la aplicación?
  - **Tipo**: Escala de 1-5
  - **Opciones**: 1 (Muy lenta) a 5 (Muy rápida)

- **Pregunta**: ¿Has experimentado algún error o crash en la aplicación?
  - **Tipo**: Sí/No
  - **Si responde Sí**: Campo de texto para describir el problema

### 5. Funcionalidades Faltantes
- **Pregunta**: ¿Qué funcionalidad te gustaría que agregáramos?
  - **Tipo**: Campo de texto libre

### 6. Mejoras Sugeridas
- **Pregunta**: ¿Qué mejorarías de la aplicación?
  - **Tipo**: Campo de texto libre

### 7. Recomendación
- **Pregunta**: ¿Recomendarías Vendify a otros comerciantes?
  - **Tipo**: Escala de 1-5
  - **Opciones**: 1 (Definitivamente no) a 5 (Definitivamente sí)

### 8. Información de Contacto (Opcional)
- **Pregunta**: ¿Te gustaría que te contactemos para más detalles?
  - **Tipo**: Sí/No
  - **Si responde Sí**: Campo de texto para email o teléfono

## Configuración del Formulario

### Configuración Recomendada
1. **Título**: "Feedback - Vendify"
2. **Descripción**: "Ayúdanos a mejorar Vendify compartiendo tu experiencia"
3. **Configuración de respuestas**: Permitir múltiples respuestas
4. **Notificaciones**: Configurar para recibir notificaciones por email

### Personalización
- Usar el tema de colores de Vendify (azul, verde, naranja)
- Agregar el logo de la aplicación si está disponible
- Configurar mensaje de agradecimiento al final

## Implementación Técnica

### En el código
```dart
const url = 'https://forms.gle/TU_FORM_ID_REAL';
```

### Manejo de Errores
El código ya incluye manejo de errores para:
- URLs inválidas
- Dispositivos sin capacidad de abrir URLs
- Errores de red

### Pruebas
Antes de lanzar:
1. Crear el formulario en Google Forms
2. Probar la URL en diferentes dispositivos
3. Verificar que se abra correctamente en el navegador
4. Probar en modo offline para verificar el manejo de errores 