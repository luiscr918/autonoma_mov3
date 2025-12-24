import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegistroScreen extends StatelessWidget {
  const RegistroScreen({super.key});

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
        Text("Registro de Usuarios"),
        TextField(
          controller: correo,
          decoration: InputDecoration(label: Text("Ingrese su correo:")),
        ),
        TextField(
          controller: contrasenia,
          decoration: InputDecoration(label: Text("Ingrese su contraseña:")),
        ),
        FilledButton.icon(
          onPressed: () => registrar(correo.text, contrasenia.text, context),
          label: Text("Registrarse"),
          icon: Icon(Icons.person_2_sharp),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          child: Text("¿Ya tiene una cuenta? inicie sesión aquí"),
        ),
      ],
    ),
  );
}

Future<void> registrar(
  String correo,
  String contrasenia,
  BuildContext context,
) async {
  try {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: correo, password: contrasenia);
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("EXITO"),
          content: Text("Registrado Correctamente"),
          
        );
      },
    );
    Navigator.pushNamed(context, '/login');
  } on FirebaseAuthException catch (e) {
    if (e.code == 'weak-password') {
      print('The password provided is too weak.');
    } else if (e.code == 'email-already-in-use') {
      print('The account already exists for that email.');
    }
  } catch (e) {
    print(e);
  }
}
