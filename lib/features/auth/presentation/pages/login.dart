import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'signup.dart';
import '../../data/models/users.dart';
import '../../../../core/data/sql.dart';

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
  bool isLoginTrue = false;
  final db = DatabaseHelper();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      var response = await db.login(
        Users(usrName: _emailCtrl.text, usrPassword: _passwordCtrl.text),
      );
      if (response == true) {
        if (!mounted) return;
        context.go('/home');
      } else {
        setState(() {
          isLoginTrue = true;
        });
      }
    }
  }

  void _navigateToHome() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Correo',
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: !isVisible,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Obligatorio' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Ingresar'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: const Text('¿No tienes cuenta? Regístrate'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _navigateToHome,
                        child: const Text('Ir al Home'),
                      ),
                      if (isLoginTrue)
                        const Text(
                          "Correo o contraseña incorrecta",
                          style: TextStyle(color: Colors.red),
                        ),
                    ],
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
