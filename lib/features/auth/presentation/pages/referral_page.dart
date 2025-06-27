import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({super.key});

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  final _referralInputCtrl = TextEditingController();

  @override
  void dispose() {
    _referralInputCtrl.dispose();
    super.dispose();
  }

  /// Copiar código de referido al portapapeles
  void _copyReferralCodeToClipboard(String referralCode) {
    Clipboard.setData(ClipboardData(text: referralCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Código de referido copiado al portapapeles'),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referidos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Éxito'),
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );

            // Si el estado incluye un usuario actualizado, actualizar el BLoC
            if (state.user != null) {
              context.read<AuthBloc>().emit(Authenticated(state.user!));
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Error'),
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          String? referralCode;
          int referralCount = 0;
          if (state is Authenticated) {
            referralCode = state.user.referralCode;
            referralCount = state.user.referralCount;
          } else if (state is AuthSuccess && state.user != null) {
            referralCode = state.user!.referralCode;
            referralCount = state.user!.referralCount;
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Tu código de referido:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    if (referralCode != null && referralCode.isNotEmpty) {
                      _copyReferralCodeToClipboard(referralCode);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200, width: 1),
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            referralCode ?? '-',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.copy,
                              size: 16,
                              color: Colors.teal.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Toca para copiar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.teal.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Referidos conseguidos: $referralCount',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                const Text('¿Tienes un código de otro usuario?',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _referralInputCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Código de referido',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final code = _referralInputCtrl.text.trim();
                    if (code.isNotEmpty) {
                      context
                          .read<AuthBloc>()
                          .add(UseReferralCodeRequested(code));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Usar código de referido'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
