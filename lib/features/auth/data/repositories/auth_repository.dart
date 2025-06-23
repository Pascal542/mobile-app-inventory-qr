import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_inventory_qr/core/utils/logger.dart';
import 'package:mobile_app_inventory_qr/core/services/device_info_service.dart';
import '../models/user_model.dart';

/// Excepciones personalizadas para autenticación
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

/// Repositorio que maneja toda la lógica de autenticación
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoService _deviceInfoService = DeviceInfoService.instance;

  /// Stream del estado de autenticación
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        // Obtener datos adicionales de Firestore
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Si no existe en Firestore, crear usuario básico
          return UserModel.fromFirebaseUser(firebaseUser);
        }
      } catch (e) {
        AppLogger.error("Error obteniendo datos de usuario", e);
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }

  /// Obtener usuario actual
  UserModel? get currentUser {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  /// Iniciar sesión con email y contraseña
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.auth("Intentando login para: $email");
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Error al obtener datos del usuario');
      }

      // Actualizar último login en Firestore
      await _updateLastLogin(user.uid);

      // Obtener datos completos del usuario
      // Buscar por UID en todos los documentos
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      } else {
        return UserModel.fromFirebaseUser(user);
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error("Error de Firebase Auth", e);
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      AppLogger.error("Error inesperado en login", e);
      throw AuthException('Error inesperado: $e');
    }
  }

  /// Registrar nuevo usuario con información completa
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      AppLogger.auth("Intentando registro para: $email");
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Error al crear usuario');
      }

      // Actualizar display name si se proporciona
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      // Obtener información del dispositivo
      final deviceInfo = await _deviceInfoService.getDeviceInfo();

      // Crear información del perfil básica
      final profileInfo = <String, dynamic>{
        'fullName': displayName ?? '',
        'registrationDate': DateTime.now().toIso8601String(),
        ...?additionalInfo,
      };

      // Crear preferencias básicas
      final preferences = <String, dynamic>{
        'language': 'es',
        'theme': 'light',
        'notificationsEnabled': true,
      };

      // Crear información del negocio vacía
      final businessInfo = <String, dynamic>{
        'businessName': '',
        'businessRuc': '',
        'businessAddress': '',
        'ownerName': displayName ?? '',
        'businessEmail': email,
      };

      // Crear usuario completo
      final userModel = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        photoURL: user.photoURL,
        phoneNumber: user.phoneNumber,
        emailVerified: user.emailVerified,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        businessInfo: businessInfo,
        roles: ['user'],
        isActive: true,
        profileInfo: profileInfo,
        preferences: preferences,
        deviceInfo: deviceInfo['platform']?.toString(),
        appVersion: deviceInfo['appVersion']?.toString(),
      );

      // Crear ID del documento con formato OwnerName_UID
      final documentId = '${displayName?.replaceAll(' ', '_') ?? 'User'}_${user.uid}';

      // Guardar en Firestore con información esencial
      await _firestore.collection('users').doc(documentId).set(userModel.toFirestore());

      // Crear subcolección para historial de sesiones (solo información básica)
      await _firestore.collection('users').doc(documentId).collection('sessions').add({
        'loginAt': Timestamp.fromDate(DateTime.now()),
        'platform': deviceInfo['platform'],
        'appVersion': deviceInfo['appVersion'],
      });

      // Crear subcolección para actividad (solo registro inicial)
      await _firestore.collection('users').doc(documentId).collection('activity').add({
        'type': 'registration',
        'timestamp': Timestamp.fromDate(DateTime.now()),
        'description': 'Usuario registrado exitosamente',
      });

      AppLogger.auth("Usuario registrado exitosamente: $email");
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error("Error de Firebase Auth en registro", e);
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      AppLogger.error("Error inesperado en registro", e);
      throw AuthException('Error inesperado: $e');
    }
  }

  /// Cerrar sesión
  Future<void> signOut() async {
    try {
      AppLogger.auth("Cerrando sesión");
      await _auth.signOut();
      AppLogger.auth("Sesión cerrada exitosamente");
    } catch (e) {
      AppLogger.error("Error al cerrar sesión", e);
      throw AuthException('Error al cerrar sesión: $e');
    }
  }

  /// Verificar conectividad con Firebase Auth
  Future<bool> testFirebaseConnection() async {
    try {
      AppLogger.auth("Probando conectividad con Firebase Auth...");
      
      // Verificar que Firebase Auth esté disponible
      if (_auth == null) {
        AppLogger.error("Firebase Auth es null");
        return false;
      }
      
      // Verificar que Firebase esté inicializado
      final currentUser = _auth.currentUser;
      AppLogger.auth("Firebase Auth disponible. Usuario actual: ${currentUser?.email ?? 'ninguno'}");
      
      return true;
    } catch (e) {
      AppLogger.error("Error probando conectividad con Firebase Auth", e);
      return false;
    }
  }

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.auth("Iniciando proceso de envío de email de recuperación a: $email");
      
      // Probar conectividad con Firebase Auth
      final isConnected = await testFirebaseConnection();
      if (!isConnected) {
        throw AuthException('Error de configuración: No se puede conectar con Firebase Auth');
      }
      
      AppLogger.auth("Firebase Auth disponible, enviando email...");
      
      // Enviar el email de recuperación
      await _auth.sendPasswordResetEmail(email: email);
      
      AppLogger.auth("Email de recuperación enviado exitosamente a: $email");
      
      // Registrar en Firestore para auditoría
      try {
        await _firestore.collection('password_resets').add({
          'email': email,
          'timestamp': Timestamp.fromDate(DateTime.now()),
          'status': 'sent',
        });
        AppLogger.auth("Registro de recuperación guardado en Firestore");
      } catch (firestoreError) {
        AppLogger.warning("No se pudo guardar registro en Firestore: $firestoreError");
        // No lanzar excepción aquí ya que el email se envió correctamente
      }
      
    } on FirebaseAuthException catch (e) {
      AppLogger.error("Error de Firebase Auth enviando email de recuperación", e);
      AppLogger.error("Código de error: ${e.code}, Mensaje: ${e.message}");
      
      // Manejar errores específicos de Firebase
      switch (e.code) {
        case 'user-not-found':
          throw AuthException('No existe una cuenta con este correo electrónico.', code: e.code);
        case 'invalid-email':
          throw AuthException('Formato de correo electrónico inválido.', code: e.code);
        case 'too-many-requests':
          throw AuthException('Demasiados intentos. Intente más tarde.', code: e.code);
        case 'network-request-failed':
          throw AuthException('Error de conexión. Verifique su internet.', code: e.code);
        case 'operation-not-allowed':
          throw AuthException('La recuperación de contraseña está deshabilitada.', code: e.code);
        default:
          throw AuthException('Error enviando email: ${e.message}', code: e.code);
      }
    } catch (e) {
      AppLogger.error("Error inesperado enviando email de recuperación", e);
      throw AuthException('Error inesperado: $e');
    }
  }

  /// Actualizar información del negocio
  Future<void> updateBusinessInfo({
    required String uid,
    required Map<String, dynamic> businessInfo,
  }) async {
    try {
      AppLogger.auth("Actualizando información del negocio para: $uid");
      
      // Buscar el documento del usuario por UID
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        
        await _firestore.collection('users').doc(documentId).update({
          'businessInfo': businessInfo,
        });

        AppLogger.auth("Información del negocio actualizada exitosamente");
      } else {
        throw AuthException('Usuario no encontrado en Firestore');
      }
    } catch (e) {
      AppLogger.error("Error actualizando información del negocio", e);
      throw AuthException('Error actualizando información: $e');
    }
  }

  /// Actualizar información del perfil
  Future<void> updateProfileInfo({
    required String uid,
    required Map<String, dynamic> profileInfo,
  }) async {
    try {
      AppLogger.auth("Actualizando información del perfil para: $uid");
      
      // Buscar el documento del usuario por UID
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        
        await _firestore.collection('users').doc(documentId).update({
          'profileInfo': profileInfo,
        });

        AppLogger.auth("Información del perfil actualizada exitosamente");
      } else {
        throw AuthException('Usuario no encontrado en Firestore');
      }
    } catch (e) {
      AppLogger.error("Error actualizando información del perfil", e);
      throw AuthException('Error actualizando perfil: $e');
    }
  }

  /// Actualizar preferencias
  Future<void> updatePreferences({
    required String uid,
    required Map<String, dynamic> preferences,
  }) async {
    try {
      AppLogger.auth("Actualizando preferencias para: $uid");
      
      // Buscar el documento del usuario por UID
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        
        await _firestore.collection('users').doc(documentId).update({
          'preferences': preferences,
        });

        AppLogger.auth("Preferencias actualizadas exitosamente");
      } else {
        throw AuthException('Usuario no encontrado en Firestore');
      }
    } catch (e) {
      AppLogger.error("Error actualizando preferencias", e);
      throw AuthException('Error actualizando preferencias: $e');
    }
  }

  /// Actualizar último login
  Future<void> _updateLastLogin(String uid) async {
    try {
      // Buscar el documento del usuario por UID
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        
        await _firestore.collection('users').doc(documentId).update({
          'lastLoginAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      AppLogger.error("Error actualizando último login", e);
      // No lanzar excepción aquí ya que no es crítico
    }
  }

  /// Manejar excepciones de Firebase Auth
  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('Usuario no registrado. Verifique su correo.', code: e.code);
      case 'wrong-password':
        return AuthException('Contraseña incorrecta. Intente nuevamente.', code: e.code);
      case 'invalid-email':
        return AuthException('Formato de correo inválido.', code: e.code);
      case 'user-disabled':
        return AuthException('Esta cuenta ha sido deshabilitada.', code: e.code);
      case 'too-many-requests':
        return AuthException('Demasiados intentos fallidos. Intente más tarde.', code: e.code);
      case 'network-request-failed':
        return AuthException('Error de conexión. Verifique su internet.', code: e.code);
      case 'email-already-in-use':
        return AuthException('Este correo ya está registrado.', code: e.code);
      case 'weak-password':
        return AuthException('La contraseña es muy débil.', code: e.code);
      case 'operation-not-allowed':
        return AuthException('El registro está deshabilitado.', code: e.code);
      default:
        return AuthException('Error de autenticación: ${e.message}', code: e.code);
    }
  }
} 