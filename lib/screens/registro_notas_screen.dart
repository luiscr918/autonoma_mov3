import 'package:flutter/material.dart';

class RegistroNotasScreen extends StatelessWidget {
  const RegistroNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: formulario());
  }
}

Widget formulario() {
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
          onPressed: () => (),
          label: Text("Guardar"),
          icon: Icon(Icons.person_2_sharp),
        ),
        TextButton(
          onPressed: () => (),
          child: Text("¿Ya tiene una cuenta? inicie sesión aquí"),
        ),
      ],
    ),
  );
}
