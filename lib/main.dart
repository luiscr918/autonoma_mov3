import 'package:autonoma_mov3/screens/leer_notas_screen.dart';
import 'package:autonoma_mov3/screens/login_screen.dart';
import 'package:autonoma_mov3/screens/registro_notas_screen.dart';
import 'package:autonoma_mov3/screens/registro_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  runApp(AppAutonoma());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //...
}

class AppAutonoma extends StatelessWidget {
  const AppAutonoma({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegistroScreen(),
        '/leer': (context) => LeerNotasScreen(),
        '/registro-notas': (context) => RegistroNotasScreen(),
      },
      home: LoginScreen(),
    );
  }
}
