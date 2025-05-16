
import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/input_decoration.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
            loginform(context)
          ],
        ),
      )
    );
  }

  SingleChildScrollView loginform(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
              children: [
                SizedBox(height: 250),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  //height: 350,
                  decoration: BoxDecoration(
                    color : Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 15,
                        offset: Offset(0, 5)
                      )
                    ]                  
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text('Login',
                      style: Theme.of(context).textTheme.headlineSmall),
                      SizedBox(height: 30),
                      Container(
                        child: Form(
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              TextFormField(
                                autocorrect: false,
                                decoration: InputDecorations.inputDecoration(hintext: "ejemplo@hotmail.com", labeltext: "Correo electronico", icono: Icon(Icons.alternate_email_rounded)),
                                validator: (value){
                                  String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                  RegExp regExp = RegExp(pattern);
                                  return regExp.hasMatch(value ?? "")? null : "El valor ingresado no es un correo";
                                },
                              ),
                              SizedBox(height: 30),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                obscureText: true,
                                decoration: InputDecorations.inputDecoration(hintext: "********", labeltext: "Contrasena", icono: Icon(Icons.lock_outline)),
                                validator: (value){
                                  return (value != null && value.length>=8) ? null : "La contraseña debe ser mayor o igual a los 8 caracteres";
                                },
                                // InputDecoration(
                                //   enabledBorder: UnderlineInputBorder(
                                //     borderSide: BorderSide(color: Colors.green)),
                                //   focusedBorder: UnderlineInputBorder(
                                //     borderSide: BorderSide(
                                //       color: Colors.green,width: 2
                                //     )
                                //   ),
                                //   hintText: "********",
                                //   labelText: "Contrasena",
                                //   prefixIcon: Icon(Icons.lock_outline),
                                // ),
                              ),
                              SizedBox(height: 30),
                              MaterialButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledColor: Colors.grey,
                                color: Colors.green,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 80, vertical: 15),
                                  child: Text(
                                    "Ingresar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, "home");
                                },
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ),
                SizedBox(height: 50),
                TextButton(
  onPressed: () {
    Navigator.pushReplacementNamed(context, 'register');
  },
  child: Text(
    "Crear una nueva cuenta",
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
              child: Icon(Icons.person_add,color:Colors.white,size: 100),
            ),
          );
  }

  Container cajaverde(Size size) {
    return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color.fromARGB(63, 63, 156, 1),
                Color.fromARGB(90, 70, 178, 1), 
              ])),
            width: double.infinity,
            height: size.height * 0.4,
          );
  }
}