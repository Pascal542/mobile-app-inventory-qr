import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Instancia global del servicio de autenticación
/// 
/// Esta instancia se puede usar en toda la aplicación para acceder
/// al servicio de autenticación de forma consistente.
ValueNotifier<AuthService> authService = ValueNotifier(AuthService()); 

/// Servicio para manejar la autenticación de usuarios
/// 
/// Este servicio proporciona métodos para:
/// - Iniciar sesión con email y contraseña
/// - Crear nuevas cuentas de usuario
/// - Obtener el usuario actual
/// - Escuchar cambios en el estado de autenticación
class AuthService {
  /// Instancia de Firebase Auth para manejar la autenticación
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  /// Obtiene el usuario actualmente autenticado
  /// 
  /// Retorna null si no hay usuario autenticado
  User? get currentUser => firebaseAuth.currentUser;

  /// Stream que emite cambios en el estado de autenticación
  /// 
  /// Útil para escuchar cuando un usuario inicia o cierra sesión
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Inicia sesión con email y contraseña
  /// 
  /// [email] - Email del usuario
  /// [password] - Contraseña del usuario
  /// 
  /// Retorna un UserCredential con la información del usuario autenticado
  /// 
  /// Lanza una excepción si las credenciales son incorrectas
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password,
    );
  }

  /// Crea una nueva cuenta de usuario
  /// 
  /// [email] - Email del nuevo usuario
  /// [password] - Contraseña del nuevo usuario
  /// 
  /// Retorna un UserCredential con la información del usuario creado
  /// 
  /// Lanza una excepción si el email ya está en uso o la contraseña es débil
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password,
    );
  }
}
