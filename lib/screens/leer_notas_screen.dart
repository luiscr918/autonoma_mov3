import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LeerNotasScreen extends StatelessWidget {
  const LeerNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(), body: Contenido());
  }
}

Widget Contenido() {
  return FutureBuilder<String?>(
    future: obtenerUid(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }
      if (snapshot.data == null) {
        return Text("Lo sentimos No haz iniciado sesion");
      }
      return Text("UID: ${snapshot.data}");
    },
  );
}

Future<String?> obtenerUid() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
