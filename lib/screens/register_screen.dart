import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/input_decoration.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            cajaverde(size),
            icono(),
            registerForm(context),
          ],
        ),
      ),
    );
  }

  Widget registerForm(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 250),
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 30),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  Text('Registro',
                      style: Theme.of(context).textTheme.headlineSmall),
                  SizedBox(height: 20),
                  TextFormField(
                    autocorrect: false,
                    decoration: InputDecorations.inputDecoration(
                      hintext: "Juan",
                      labeltext: "Nombre",
                      icono: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : "Ingrese su nombre",
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    autocorrect: false,
                    decoration: InputDecorations.inputDecoration(
                      hintext: "Pérez",
                      labeltext: "Apellido",
                      icono: Icon(Icons.person),
                    ),
                    validator: (value) =>
                        value != null && value.isNotEmpty
                            ? null
                            : "Ingrese su apellido",
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    autocorrect: false,
                    decoration: InputDecorations.inputDecoration(
                      hintext: "ejemplo@gmail.com",
                      labeltext: "Correo electrónico",
                      icono: Icon(Icons.alternate_email_rounded),
                    ),
                    validator: (value) {
                      String pattern =
                          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                      RegExp regExp = RegExp(pattern);
                      return regExp.hasMatch(value ?? "")
                          ? null
                          : "Ingrese un correo válido";
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    autocorrect: false,
                    decoration: InputDecorations.inputDecoration(
                      hintext: "********",
                      labeltext: "Contraseña",
                      icono: Icon(Icons.lock_outline),
                    ),
                    validator: (value) => value != null && value.length >= 8
                        ? null
                        : "Mínimo 8 caracteres",
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    autocorrect: false,
                    decoration: InputDecorations.inputDecoration(
                      hintext: "********",
                      labeltext: "Confirmar Contraseña",
                      icono: Icon(Icons.lock_open),
                    ),
                    validator: (value) => value != null && value.length >= 8
                        ? null
                        : "Confirme su contraseña",
                  ),
                  SizedBox(height: 30),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    disabledColor: Colors.grey,
                    color: Colors.green,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                      child: Text(
                        "Registrarse",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, 'home');
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 50),
          TextButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, 'login');
  },
  child: Text(
    "¿Ya tienes una cuenta? Inicia sesión",
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.green,),
  ),
),
        ],
      ),
    );
  }

  SafeArea icono() {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(top: 40),
        width: double.infinity,
        child: Icon(Icons.app_registration, color: Colors.white, size: 100),
      ),
    );
  }

  Container cajaverde(Size size) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(63, 63, 156, 1),
            Color.fromARGB(90, 70, 178, 1),
          ],
        ),
      ),
      width: double.infinity,
      height: size.height * 0.4,
    );
  }
}
