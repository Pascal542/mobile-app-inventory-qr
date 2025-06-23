import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

/// Excepciones personalizadas para autenticación
class AuthException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AuthException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'AuthException: $message';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool isVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
      AuthSignInRequested(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            AppSnackbar.success(context, '✅ Bienvenido, ${state.user.displayName ?? state.user.email}');
            context.go('/home');
          } else if (state is AuthError) {
            AppSnackbar.error(context, '❌ ${state.message}');
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "lib/assets/login.png",
                          width: 100,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Iniciar Sesión',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return TextFormField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Correo',
                                prefixIcon: Icon(Icons.email),
                                hintText: 'ejemplo@correo.com',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.none,
                              validator: FormValidators.email,
                              enabled: state is! AuthLoading,
                              onFieldSubmitted: (_) => _handleLogin(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return TextFormField(
                              controller: _passwordCtrl,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
                                  onPressed: () {
                                    setState(() {
                                      isVisible = !isVisible;
                                    });
                                  },
                                ),
                              ),
                              obscureText: !isVisible,
                              textCapitalization: TextCapitalization.none,
                              validator: FormValidators.password,
                              enabled: state is! AuthLoading,
                              onFieldSubmitted: (_) => _handleLogin(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.go('/forgot_password'),
                            child: const Text('¿Olvidaste tu contraseña?'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: state is AuthLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return TextButton(
                              onPressed: state is AuthLoading ? null : () => context.go('/signup'),
                              child: const Text('¿No tienes cuenta? Regístrate'),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}