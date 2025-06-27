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
        print(
            '[DEBUG] authStateChanges: Buscando usuario con UID: \'${firebaseUser.uid}\'');
        final querySnapshot = await _firestore
            .collection('users')
            .where('uid', isEqualTo: firebaseUser.uid)
            .limit(1)
            .get();
        print(
            '[DEBUG] authStateChanges: Docs encontrados: \'${querySnapshot.docs.length}\'');
        if (querySnapshot.docs.isNotEmpty) {
          print(
              '[DEBUG] authStateChanges: Data: \'${querySnapshot.docs.first.data()}\'');
          try {
            final user = UserModel.fromFirestore(querySnapshot.docs.first);
            print(
                '[DEBUG] authStateChanges: UserModel parseado correctamente: \'${user.uid}\'');
            return user;
          } catch (e) {
            print('[DEBUG] authStateChanges: Error parseando UserModel: $e');
            return null;
          }
        } else {
          print(
              '[DEBUG] authStateChanges: No se encontró usuario en Firestore');
          return UserModel.fromFirebaseUser(firebaseUser);
        }
      } catch (e) {
        print('[DEBUG] authStateChanges: Error: $e');
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
      print('[DEBUG] Iniciando registro para: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('[DEBUG] Usuario creado en Firebase Auth');

      final user = userCredential.user;
      if (user == null) {
        throw AuthException('Error al crear usuario');
      }
      print('[DEBUG] UID del usuario: ${user.uid}');

      // Actualizar display name si se proporciona
      if (displayName != null) {
        print('[DEBUG] Actualizando display name: $displayName');
        await user.updateDisplayName(displayName);
        print('[DEBUG] Display name actualizado');
      }

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

      // Generar código de referido único (usar el UID completo)
      final referralCode = user.uid;

      // Crear usuario completo
      print('[DEBUG] Creando UserModel');
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
        deviceInfo: 'Android', // Valor fijo por ahora
        appVersion: '1.0.0', // Valor fijo por ahora
        referralCode: referralCode,
        referralCount: 0,
      );
      print('[DEBUG] UserModel creado');

      // Crear ID del documento con formato OwnerName_UID
      final documentId =
          '${displayName?.replaceAll(' ', '_') ?? 'User'}_${user.uid}';

      // Guardar en Firestore con información esencial
      print('[DEBUG] Guardando usuario en Firestore:');
      print('[DEBUG] Colección: users');
      print('[DEBUG] documentId: \'${documentId}\'');
      print('[DEBUG] Datos a guardar: ${userModel.toFirestore()}');

      await _firestore
          .collection('users')
          .doc(documentId)
          .set(userModel.toFirestore());
      print('[DEBUG] Usuario guardado en Firestore exitosamente');

      AppLogger.auth("Usuario registrado exitosamente: $email");
      print('[DEBUG] Registro completado exitosamente');
      return userModel;
    } on FirebaseAuthException catch (e) {
      AppLogger.error("Error de Firebase Auth en registro", e);
      print('[DEBUG] Error de Firebase Auth: ${e.code} - ${e.message}');
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      AppLogger.error("Error inesperado en registro", e);
      print('[DEBUG] Error inesperado: $e');
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
      AppLogger.auth(
          "Firebase Auth disponible. Usuario actual: ${currentUser?.email ?? 'ninguno'}");

      return true;
    } catch (e) {
      AppLogger.error("Error probando conectividad con Firebase Auth", e);
      return false;
    }
  }

  /// Enviar email de recuperación de contraseña
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      AppLogger.auth(
          "Iniciando proceso de envío de email de recuperación a: $email");

      // Probar conectividad con Firebase Auth
      final isConnected = await testFirebaseConnection();
      if (!isConnected) {
        throw AuthException(
            'Error de configuración: No se puede conectar con Firebase Auth');
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
        AppLogger.warning(
            "No se pudo guardar registro en Firestore: $firestoreError");
        // No lanzar excepción aquí ya que el email se envió correctamente
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.error(
          "Error de Firebase Auth enviando email de recuperación", e);
      AppLogger.error("Código de error: ${e.code}, Mensaje: ${e.message}");

      // Manejar errores específicos de Firebase
      switch (e.code) {
        case 'user-not-found':
          throw AuthException(
              'No existe una cuenta con este correo electrónico.',
              code: e.code);
        case 'invalid-email':
          throw AuthException('Formato de correo electrónico inválido.',
              code: e.code);
        case 'too-many-requests':
          throw AuthException('Demasiados intentos. Intente más tarde.',
              code: e.code);
        case 'network-request-failed':
          throw AuthException('Error de conexión. Verifique su internet.',
              code: e.code);
        case 'operation-not-allowed':
          throw AuthException(
              'La recuperación de contraseña está deshabilitada.',
              code: e.code);
        default:
          throw AuthException('Error enviando email: ${e.message}',
              code: e.code);
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
        return AuthException('Usuario no registrado. Verifique su correo.',
            code: e.code);
      case 'wrong-password':
        return AuthException('Contraseña incorrecta. Intente nuevamente.',
            code: e.code);
      case 'invalid-email':
        return AuthException('Formato de correo inválido.', code: e.code);
      case 'user-disabled':
        return AuthException('Esta cuenta ha sido deshabilitada.',
            code: e.code);
      case 'too-many-requests':
        return AuthException('Demasiados intentos fallidos. Intente más tarde.',
            code: e.code);
      case 'network-request-failed':
        return AuthException('Error de conexión. Verifique su internet.',
            code: e.code);
      case 'email-already-in-use':
        return AuthException('Este correo ya está registrado.', code: e.code);
      case 'weak-password':
        return AuthException('La contraseña es muy débil.', code: e.code);
      case 'operation-not-allowed':
        return AuthException('El registro está deshabilitado.', code: e.code);
      default:
        return AuthException('Error de autenticación: ${e.message}',
            code: e.code);
    }
  }

  /// Obtener datos actualizados del usuario actual (sin requerir contraseña)
  Future<UserModel> refreshCurrentUserData() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        throw AuthException('No hay usuario autenticado');
      }

      // Buscar datos actualizados en Firestore
      final querySnapshot = await _firestore
          .collection('users')
          .where('uid', isEqualTo: firebaseUser.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(querySnapshot.docs.first);
      } else {
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    } catch (e) {
      AppLogger.error("Error refrescando datos del usuario", e);
      throw AuthException('Error refrescando datos: $e');
    }
  }

  /// Buscar usuario por UID (código de referido)
  Future<UserModel?> getUserByUid(String uid) async {
    // Buscar por query usando el campo uid
    final querySnapshot = await _firestore
        .collection('users')
        .where('uid', isEqualTo: uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return UserModel.fromFirestore(querySnapshot.docs.first);
    }
    return null;
  }

  /// Usar un código de referido (UID real)
  Future<void> useReferralCode(
      {required UserModel currentUser, required String code}) async {
    print('[DEBUG] useReferralCode: Iniciando proceso');
    print('[DEBUG] useReferralCode: Usuario actual UID: ${currentUser.uid}');
    print('[DEBUG] useReferralCode: Código a usar: $code');
    print(
        '[DEBUG] useReferralCode: Usuario ya usó código: ${currentUser.usedReferralCode}');

    // No permitir usar el propio UID
    if (currentUser.uid == code) {
      print(
          '[DEBUG] useReferralCode: Error - Usuario intenta usar su propio código');
      throw AuthException('No puedes usar tu propio código de referido');
    }

    // No permitir usar más de un código
    if (currentUser.usedReferralCode != null) {
      print('[DEBUG] useReferralCode: Error - Usuario ya usó un código');
      throw AuthException('Ya usaste un código de referido');
    }

    // Buscar el usuario dueño del UID
    print('[DEBUG] useReferralCode: Buscando usuario dueño del código');
    final referredUser = await getUserByUid(code);
    if (referredUser == null) {
      print(
          '[DEBUG] useReferralCode: Error - Código no válido, usuario no encontrado');
      throw AuthException('Código de referido no válido');
    }
    print(
        '[DEBUG] useReferralCode: Usuario dueño encontrado: ${referredUser.email}');

    // Buscar el documento del usuario actual por UID
    print('[DEBUG] useReferralCode: Buscando documento del usuario actual');
    final currentUserQuery = await _firestore
        .collection('users')
        .where('uid', isEqualTo: currentUser.uid)
        .limit(1)
        .get();

    if (currentUserQuery.docs.isEmpty) {
      print(
          '[DEBUG] useReferralCode: Error - Usuario actual no encontrado en Firestore');
      throw AuthException('Usuario actual no encontrado en Firestore');
    }
    print(
        '[DEBUG] useReferralCode: Documento del usuario actual encontrado: ${currentUserQuery.docs.first.id}');

    // Buscar el documento del usuario referido por UID
    print('[DEBUG] useReferralCode: Buscando documento del usuario referido');
    final referredUserQuery = await _firestore
        .collection('users')
        .where('uid', isEqualTo: referredUser.uid)
        .limit(1)
        .get();

    if (referredUserQuery.docs.isEmpty) {
      print(
          '[DEBUG] useReferralCode: Error - Usuario referido no encontrado en Firestore');
      throw AuthException('Usuario referido no encontrado en Firestore');
    }
    print(
        '[DEBUG] useReferralCode: Documento del usuario referido encontrado: ${referredUserQuery.docs.first.id}');

    // Actualizar el usuario actual con el código usado
    print(
        '[DEBUG] useReferralCode: Actualizando usuario actual con código usado');
    await _firestore
        .collection('users')
        .doc(currentUserQuery.docs.first.id)
        .update({
      'usedReferralCode': code,
    });
    print('[DEBUG] useReferralCode: Usuario actual actualizado');

    // Sumar uno al referralCount del dueño del UID
    print(
        '[DEBUG] useReferralCode: Incrementando contador de referidos del dueño');
    await _firestore
        .collection('users')
        .doc(referredUserQuery.docs.first.id)
        .update({
      'referralCount': FieldValue.increment(1),
    });
    print('[DEBUG] useReferralCode: Contador de referidos incrementado');
    print('[DEBUG] useReferralCode: Proceso completado exitosamente');
  }
}
