import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app_inventory_qr/core/utils/logger.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;
  final Map<String, dynamic>? additionalInfo;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
    this.additionalInfo,
  });

  @override
  List<Object?> get props => [email, password, displayName, additionalInfo];
}

class AuthSignOutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthUpdateBusinessInfoRequested extends AuthEvent {
  final String uid;
  final Map<String, dynamic> businessInfo;

  const AuthUpdateBusinessInfoRequested({
    required this.uid,
    required this.businessInfo,
  });

  @override
  List<Object?> get props => [uid, businessInfo];
}

class AuthUpdateProfileInfoRequested extends AuthEvent {
  final String uid;
  final Map<String, dynamic> profileInfo;

  const AuthUpdateProfileInfoRequested({
    required this.uid,
    required this.profileInfo,
  });

  @override
  List<Object?> get props => [uid, profileInfo];
}

class AuthUpdatePreferencesRequested extends AuthEvent {
  final String uid;
  final Map<String, dynamic> preferences;

  const AuthUpdatePreferencesRequested({
    required this.uid,
    required this.preferences,
  });

  @override
  List<Object?> get props => [uid, preferences];
}

class UseReferralCodeRequested extends AuthEvent {
  final String code;
  UseReferralCodeRequested(this.code);
  @override
  List<Object?> get props => [code];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final String? code;

  const AuthError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class AuthSuccess extends AuthState {
  final String message;
  final UserModel? user;

  const AuthSuccess(this.message, {this.user});

  @override
  List<Object?> get props => [message, user];
}

class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object?> get props => [email];
}

/// BLoC que maneja toda la lógica de autenticación
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthUpdateBusinessInfoRequested>(_onAuthUpdateBusinessInfoRequested);
    on<AuthUpdateProfileInfoRequested>(_onAuthUpdateProfileInfoRequested);
    on<AuthUpdatePreferencesRequested>(_onAuthUpdatePreferencesRequested);
    on<UseReferralCodeRequested>(_onUseReferralCodeRequested);
  }

  /// Verificar estado de autenticación
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = _authRepository.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      AppLogger.error("Error verificando autenticación", e);
      emit(AuthError('Error verificando autenticación: $e'));
    }
  }

  /// Iniciar sesión
  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      final user = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      emit(Authenticated(user));
    } catch (e) {
      AppLogger.error("Error en login", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  /// Registrar usuario
  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('[DEBUG] BLoC: Iniciando registro para ${event.email}');
      emit(AuthLoading());

      print('[DEBUG] BLoC: Llamando al repositorio');
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
        additionalInfo: event.additionalInfo,
      );
      print('[DEBUG] BLoC: Usuario registrado exitosamente');

      print('[DEBUG] BLoC: Emitiendo Authenticated');
      emit(Authenticated(user));
      print('[DEBUG] BLoC: Estado Authenticated emitido');
    } catch (e) {
      print('[DEBUG] BLoC: Error en registro: $e');
      AppLogger.error("Error en registro", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  /// Cerrar sesión
  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await _authRepository.signOut();

      emit(Unauthenticated());
    } catch (e) {
      AppLogger.error("Error al cerrar sesión", e);
      emit(AuthError('Error al cerrar sesión: $e'));
    }
  }

  /// Enviar email de recuperación
  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print(
          "DEBUG: BLoC recibió solicitud de recuperación para: ${event.email}");
      emit(AuthLoading());

      print("DEBUG: Llamando al repositorio para enviar email...");
      await _authRepository.sendPasswordResetEmail(event.email);

      print("DEBUG: Email enviado exitosamente, emitiendo AuthSuccess");
      emit(AuthSuccess('Email de recuperación enviado exitosamente'));
    } catch (e) {
      print("DEBUG: Error en BLoC: $e");
      AppLogger.error("Error enviando email de recuperación", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  /// Actualizar información del negocio
  Future<void> _onAuthUpdateBusinessInfoRequested(
    AuthUpdateBusinessInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await _authRepository.updateBusinessInfo(
        uid: event.uid,
        businessInfo: event.businessInfo,
      );

      emit(AuthSuccess('Información del negocio actualizada exitosamente'));
    } catch (e) {
      AppLogger.error("Error actualizando información del negocio", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  /// Actualizar información del perfil
  Future<void> _onAuthUpdateProfileInfoRequested(
    AuthUpdateProfileInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await _authRepository.updateProfileInfo(
        uid: event.uid,
        profileInfo: event.profileInfo,
      );

      emit(AuthSuccess('Perfil actualizado exitosamente'));
    } catch (e) {
      AppLogger.error("Error actualizando perfil", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  /// Actualizar preferencias
  Future<void> _onAuthUpdatePreferencesRequested(
    AuthUpdatePreferencesRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      await _authRepository.updatePreferences(
        uid: event.uid,
        preferences: event.preferences,
      );

      emit(AuthSuccess('Preferencias actualizadas exitosamente'));
    } catch (e) {
      AppLogger.error("Error actualizando preferencias", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error inesperado: $e'));
      }
    }
  }

  Future<void> _onUseReferralCodeRequested(
    UseReferralCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print('[DEBUG] BLoC: Iniciando uso de código de referido: ${event.code}');
      final currentUser = _authRepository.currentUser;
      if (currentUser == null) {
        print('[DEBUG] BLoC: Error - Usuario no autenticado');
        emit(AuthError('Usuario no autenticado'));
        return;
      }
      print('[DEBUG] BLoC: Usuario actual: ${currentUser.email}');

      print('[DEBUG] BLoC: Llamando al repositorio para usar código');
      await _authRepository.useReferralCode(
          currentUser: currentUser, code: event.code.trim());
      print('[DEBUG] BLoC: Código usado exitosamente');

      // Refrescar datos del usuario solo si fue exitoso
      print('[DEBUG] BLoC: Refrescando datos del usuario');
      final updatedUser = await _authRepository.refreshCurrentUserData();
      print('[DEBUG] BLoC: Datos del usuario refrescados');

      emit(AuthSuccess('¡Código de referido usado correctamente!',
          user: updatedUser));
      print('[DEBUG] BLoC: Estado AuthSuccess emitido');
    } catch (e) {
      print('[DEBUG] BLoC: Error usando código de referido: $e');
      AppLogger.error("Error usando código de referido", e);
      if (e is AuthException) {
        emit(AuthError(e.message, code: e.code));
      } else {
        emit(AuthError('Error usando el código de referido: $e'));
      }
    }
  }
}
