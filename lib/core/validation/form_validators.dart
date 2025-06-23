import 'package:flutter/services.dart';

/// Sistema de validación centralizado para formularios
class FormValidators {
  // Mensajes de error consistentes
  static const String _requiredMessage = 'Este campo es obligatorio';
  static const String _invalidEmailMessage = 'Ingrese un correo electrónico válido';
  static const String _invalidDniMessage = 'El DNI debe tener 8 dígitos';
  static const String _invalidRucMessage = 'El RUC debe tener 11 dígitos';
  static const String _invalidRucPrefixMessage = 'El RUC debe empezar con 10, 15, 16, 17 o 20';
  static const String _invalidPasswordMessage = 'La contraseña debe tener al menos 6 caracteres';
  static const String _passwordsNotMatchMessage = 'Las contraseñas no coinciden';
  static const String _invalidQuantityMessage = 'La cantidad debe ser mayor a 0';
  static const String _invalidPriceMessage = 'El precio debe ser mayor a 0';
  static const String _invalidNameMessage = 'El nombre debe tener al menos 2 caracteres';
  static const String _invalidPhoneMessage = 'Ingrese un número de teléfono válido';
  static const String _invalidUrlMessage = 'Ingrese una URL válida';

  /// Validar campo requerido
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    return null;
  }

  /// Validar email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return _invalidEmailMessage;
    }
    
    return null;
  }

  /// Validar DNI (8 dígitos)
  static String? dni(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (value.length != 8) {
      return _invalidDniMessage;
    }
    
    return null;
  }

  /// Validar RUC (11 dígitos con prefijos válidos)
  static String? ruc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (value.length != 11) {
      return _invalidRucMessage;
    }
    
    final validPrefixes = ['10', '15', '16', '17', '20'];
    if (!validPrefixes.any((prefix) => value.startsWith(prefix))) {
      return _invalidRucPrefixMessage;
    }
    
    return null;
  }

  /// Validar contraseña
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return _requiredMessage;
    }
    
    if (value.length < 6) {
      return _invalidPasswordMessage;
    }
    
    return null;
  }

  /// Validar confirmación de contraseña
  static String? confirmPassword(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return _requiredMessage;
    }
    
    if (password != confirmPassword) {
      return _passwordsNotMatchMessage;
    }
    
    return null;
  }

  /// Validar cantidad (número entero positivo)
  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final quantity = int.tryParse(value);
    if (quantity == null || quantity <= 0) {
      return _invalidQuantityMessage;
    }
    
    return null;
  }

  /// Validar precio (número decimal positivo)
  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return _invalidPriceMessage;
    }
    
    return null;
  }

  /// Validar nombre (mínimo 2 caracteres)
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (value.trim().length < 2) {
      return _invalidNameMessage;
    }
    
    return null;
  }

  /// Validar teléfono
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final phoneRegex = RegExp(r'^[0-9+\-\s\(\)]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return _invalidPhoneMessage;
    }
    
    return null;
  }

  /// Validar URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final urlRegex = RegExp(r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$');
    if (!urlRegex.hasMatch(value.trim())) {
      return _invalidUrlMessage;
    }
    
    return null;
  }

  /// Validar longitud mínima
  static String? minLength(String? value, int minLength, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (value.trim().length < minLength) {
      return customMessage ?? 'Debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  /// Validar longitud máxima
  static String? maxLength(String? value, int maxLength, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (value.trim().length > maxLength) {
      return customMessage ?? 'Debe tener máximo $maxLength caracteres';
    }
    
    return null;
  }

  /// Validar rango de longitud
  static String? lengthRange(String? value, int minLength, int maxLength, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final length = value.trim().length;
    if (length < minLength || length > maxLength) {
      return customMessage ?? 'Debe tener entre $minLength y $maxLength caracteres';
    }
    
    return null;
  }

  /// Validar número entero
  static String? integer(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (int.tryParse(value) == null) {
      return customMessage ?? 'Debe ser un número entero';
    }
    
    return null;
  }

  /// Validar número decimal
  static String? decimal(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (double.tryParse(value) == null) {
      return customMessage ?? 'Debe ser un número válido';
    }
    
    return null;
  }

  /// Validar que sea un número positivo
  static String? positive(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return customMessage ?? 'Debe ser un número mayor a 0';
    }
    
    return null;
  }

  /// Validar que sea un número no negativo
  static String? nonNegative(String? value, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return customMessage ?? 'Debe ser un número mayor o igual a 0';
    }
    
    return null;
  }

  /// Combinar múltiples validadores
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Validar con mensaje personalizado
  static String? custom(String? value, bool Function(String) condition, String message) {
    if (value == null || value.trim().isEmpty) {
      return _requiredMessage;
    }
    
    if (!condition(value)) {
      return message;
    }
    
    return null;
  }
}

/// Filtros de entrada para TextFormField
class InputFormatters {
  /// Solo números
  static final numbersOnly = FilteringTextInputFormatter.digitsOnly;
  
  /// Solo letras y espacios
  static final lettersOnly = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]'));
  
  /// Solo letras, números y espacios
  static final alphanumeric = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9áéíóúÁÉÍÓÚñÑ\s]'));
  
  /// Solo números y decimales
  static final decimal = FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));
  
  /// Solo números, letras y algunos símbolos para emails
  static final email = FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]'));
  
  /// Solo números y algunos símbolos para teléfonos
  static final phone = FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]'));
}

/// Configuraciones predefinidas para TextFormField
class TextFieldConfigs {
  /// Configuración para campo de email
  static final email = {
    'keyboardType': TextInputType.emailAddress,
    'inputFormatters': [InputFormatters.email],
  };
  
  /// Configuración para campo de contraseña
  static final password = {
    'obscureText': true,
  };
  
  /// Configuración para campo numérico
  static final number = {
    'keyboardType': TextInputType.number,
    'inputFormatters': [InputFormatters.numbersOnly],
  };
  
  /// Configuración para campo decimal
  static final decimal = {
    'keyboardType': const TextInputType.numberWithOptions(decimal: true),
    'inputFormatters': [InputFormatters.decimal],
  };
  
  /// Configuración para campo de teléfono
  static final phone = {
    'keyboardType': TextInputType.phone,
    'inputFormatters': [InputFormatters.phone],
  };
  
  /// Configuración para campo de nombre
  static final name = {
    'textCapitalization': TextCapitalization.words,
    'inputFormatters': [InputFormatters.lettersOnly],
  };
} 