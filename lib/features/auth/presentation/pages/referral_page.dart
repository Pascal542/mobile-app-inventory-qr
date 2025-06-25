import 'package:flutter/material.dart';
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
              SnackBar(content: Text(state.message ?? 'Éxito')),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Error'), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final authState = context.read<AuthBloc>().state;
          String? referralCode;
          int referralCount = 0;
          if (authState is Authenticated) {
            referralCode = authState.user.referralCode;
            referralCount = authState.user.referralCount;
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Tu código de referido:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      referralCode ?? '-',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Referidos conseguidos: $referralCount', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 32),
                const Text('¿Tienes un código de otro usuario?', style: TextStyle(fontSize: 16)),
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
                      context.read<AuthBloc>().add(UseReferralCodeRequested(code));
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