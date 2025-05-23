import 'package:flutter/material.dart';
import 'package:flutter_application_1/Authentication/login.dart';
import 'package:flutter_application_1/JsonModels/users.dart';
import 'package:flutter_application_1/SQLite/sql.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7E6), // Color fondo claro
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Icono
                Image.asset(
                  "lib/assets/login.png",
                  width: 100,
                ),
                const SizedBox(height: 10),

                const Text(
                  "Vendify",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  "Crear nueva cuenta",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 25),

                // Usuario
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2C789),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: username,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Correo',
                      hintStyle: TextStyle(
                        color: Color(0xFF867A36),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Correo requerido' : null,
                  ),
                ),

                // Contraseña
                Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2C789),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: password,
                    obscureText: !isVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Contraseña',
                      hintStyle: const TextStyle(
                        color: Color(0xFF867A36),
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Contraseña requerida' : null,
                  ),
                ),

                // Confirmar contraseña
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2C789),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextFormField(
                    controller: confirmPassword,
                    obscureText: !isVisible,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Confirmar contraseña',
                      hintStyle: const TextStyle(
                        color: Color(0xFF867A36),
                        fontWeight: FontWeight.bold,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          setState(() {
                            isVisible = !isVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Confirmar contraseña requerida';
                      } else if (password.text != confirmPassword.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ),

                // Botón SIGN UP
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFD2C789),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final db = DatabaseHelper();
                        db
                            .signup(Users(
                              usrName: username.text,
                              usrPassword: password.text,
                            ))
                            .whenComplete(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        });
                      }
                    },
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Color(0xFF9E4C57),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enlace a login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿Ya tienes una cuenta?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Inicia sesión",
                        style: TextStyle(
                          color: Color(0xFFDE5D6A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
