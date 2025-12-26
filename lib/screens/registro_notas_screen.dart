import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RegistroNotasScreen extends StatelessWidget {
  const RegistroNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Cuerpo());
  }
}

class Cuerpo extends StatelessWidget {
  const Cuerpo({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: obtenerUid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        // 2. Manejo de errores o usuario no logueado
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("Lo sentimos, no has iniciado sesión"),
          );
        }
        return formulario(snapshot.data, context);
      },
    );
  }
}

Widget formulario(String? idUsuario, context) {
  TextEditingController titulo = TextEditingController();
  TextEditingController descripcion = TextEditingController();
  TextEditingController precio = TextEditingController();

  return Center(
    child: Column(
      children: [
        Text("Registro de Notas de Gastos"),
        TextField(
          controller: titulo,
          decoration: InputDecoration(label: Text("Ingrese el titulo:")),
        ),
        TextField(
          controller: descripcion,
          decoration: InputDecoration(label: Text("Ingrese la descripcion:")),
        ),
        TextField(
          controller: precio,
          decoration: InputDecoration(label: Text("Ingrese el precio:")),
        ),
        FilledButton.icon(
          onPressed: () => guardarNota(
            titulo.text,
            descripcion.text,
            double.parse(precio.text),
            idUsuario,
            context,
          ),
          label: Text("Guardar"),
          icon: Icon(Icons.person_2_sharp),
        ),
      ],
    ),
  );
}

Future<String?> obtenerUid() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}

Future<void> guardarNota(
  String titulo,
  String descripcion,
  double precio,
  String? usuarioId,
  context,
) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("notas/$usuarioId");

  await ref.push().set({
    "titulo": titulo,
    "descripcion": descripcion,
    "precio": precio,
  });
  Navigator.pushNamed(context, '/leer');
}
