import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/validation/form_validators.dart';
import '../../../../core/widgets/app_snackbar.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _handlePasswordReset() {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailCtrl.text.trim();
    print("DEBUG: Intentando enviar email de recuperación a: $email");
    
    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(
      AuthPasswordResetRequested(
        email: email,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            setState(() => _isLoading = false);
            AppSnackbar.success(
              context, 
              '✅ Email de recuperación enviado. Revisa tu bandeja de entrada.'
            );
            context.go('/login');
          } else if (state is AuthError) {
            setState(() => _isLoading = false);
            AppSnackbar.error(context, '❌ ${state.message}');
          } else if (state is AuthLoading) {
            setState(() => _isLoading = true);
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
                        Icon(
                          Icons.lock_reset,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '¿Olvidaste tu contraseña?',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                            hintText: 'ejemplo@correo.com',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          validator: FormValidators.email,
                          onFieldSubmitted: (_) => _handlePasswordReset(),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading ? null : _handlePasswordReset,
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
                                        'Enviar Email de Recuperación',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Volver al Login'),
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