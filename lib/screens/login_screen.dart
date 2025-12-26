import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: formulario(context));
  }
}

Widget formulario(BuildContext context) {
  TextEditingController correo = TextEditingController();
  TextEditingController contrasenia = TextEditingController();
  return Center(
    child: Column(
      children: [
        Text("Bienvenido a el sistema de notas de gasto"),
        TextField(
          controller: correo,
          decoration: InputDecoration(label: Text("Ingrese su correo:")),
        ),
        TextField(
          controller: contrasenia,
          decoration: InputDecoration(label: Text("Ingrese su contraseña:")),
        ),
        FilledButton.icon(
          onPressed: () => loguearse(correo.text, contrasenia.text, context),
          label: Text("Iniciar Sesión"),
          icon: Icon(Icons.person_2_sharp),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/registro'),
          child: Text("No tiene una cuenta? registrese aquí"),
        ),
      ],
    ),
  );
}

Future<void> loguearse(String correo, String contrasenia, context) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: correo,
      password: contrasenia,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("EXITO"),
          content: Text("Inicio de sesión Exitoso"),
        );
      },
    );
    Navigator.pushNamed(context, '/leer');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text("Error al iniciar Sesion"),
        );
      },
    );
  }
}
