import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LeerNotasScreen extends StatelessWidget {
  const LeerNotasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Notas"),
        actions: [
          IconButton(
            tooltip: "Cerrar sesión",
            onPressed: () async {
              // 1. Cerramos la sesión en Firebase
              await FirebaseAuth.instance.signOut();

              // 2. Navegamos a la pantalla de login
              // Usamos pushReplacementNamed para que el usuario no pueda volver atrás
              Navigator.pushReplacementNamed(context, '/login');
            },
            icon: const Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: Contenido(),
      // Boton para agregar nueva nota
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/registro-notas'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Contenido extends StatelessWidget {
  const Contenido({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: obtenerUid(),
      builder: (context, snapshot) {
        // 1. Manejo de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Manejo de errores o usuario no logueado
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text("Lo sentimos, no has iniciado sesión"),
          );
        }

        // 3. Si tenemos UID, consultamos las notas
        // Usamos otro FutureBuilder para la base de datos
        return StreamBuilder(
          stream: FirebaseDatabase.instance
              .ref('notas/${snapshot.data}')
              .onValue,
          builder: (context, notasSnapshot) {
            if (notasSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (notasSnapshot.hasError) {
              return Center(
                child: Column(
                  children: [
                    const Text("Error al cargar las notas"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registro-notas'),
                      child: const Text("registrar notas"),
                    ),
                  ],
                ),
              );
            }

            if (!notasSnapshot.hasData ||
                notasSnapshot.data!.snapshot.value == null) {
              return Center(
                child: Column(
                  children: [
                    const Text("No tienes notas guardadas aún"),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/registro-notas'),
                      child: const Text("registrar notas"),
                    ),
                  ],
                ),
              );
            }
            final data = notasSnapshot.data!.snapshot.value;
            return listaNotas(data);
          },
        );
      },
    );
  }
}

Future<String?> obtenerUid() async {
  User? user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}

Future<List<dynamic>> mapearLista(Object? data) async {
  List<dynamic> notas = [];
  Map mapNotas = data as Map;
  mapNotas.forEach((clave, valor) {
    notas.add({
      "id": clave,
      "titulo": valor['titulo'],
      "descripcion": valor['descripcion'],
      "precio": valor['precio'],
    });
  });
  return notas;
}

Widget listaNotas(Object? data) {
  return FutureBuilder<List<dynamic>>(
    future: mapearLista(data),
    builder: (context, snapshot) {
      // 1. Verificar si está cargando el mapeo
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // 2. Verificar si hubo un error o no hay datos
      if (!snapshot.hasData ||
          snapshot.data == null ||
          snapshot.data!.isEmpty) {
        return const Center(child: Text("No se pudieron procesar las notas"));
      }

      // 3. Ahora sí es seguro usar los datos
      List datita = snapshot.data!;

      return ListView.builder(
        itemCount: datita.length,
        itemBuilder: (context, index) {
          final item = datita[index];
          return ListTile(
            onTap: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                formularioEditar(context, uid, item);
              }
            },
            title: Text("Titulo: ${item['titulo'] ?? "Sin título"}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Descripción: ${item['descripcion']}"),
                Text("\$:${item['precio']}"),
              ],
            ),
            trailing: IconButton(
              onPressed: () async {
                // Obtenemos el UID actual para borrar correctamente
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await eliminar(uid, item['id']);
                }
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          );
        },
      );
    },
  );
}

Future<void> eliminar(String userId, String notaId) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref(
    "notas/$userId/$notaId",
  );
  await ref.remove();
}

void formularioEditar(
  BuildContext context,
  String userId,
  Map<dynamic, dynamic> item,
) {
  TextEditingController titulo = TextEditingController(text: item['titulo']);
  TextEditingController descripcion = TextEditingController(
    text: item['descripcion'],
  );
  TextEditingController precio = TextEditingController(
    text: item['precio'].toString(),
  );

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Editar Nota"),
        content: SingleChildScrollView(
          // Para evitar errores de espacio con el teclado
          child: Column(
            mainAxisSize: MainAxisSize.min, // El diálogo se ajusta al contenido
            children: [
              TextField(
                controller: titulo,
                decoration: const InputDecoration(labelText: "Título"),
              ),
              TextField(
                controller: descripcion,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              TextField(
                controller: precio,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Precio"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () async {
              // Llamamos a una función específica para actualizar (update)
              await actualizarNota(
                userId,
                item['id'], // El ID de la nota que estamos editando
                titulo.text,
                descripcion.text,
                double.parse(precio.text),
              );
              Navigator.pop(context); // Cerrar el diálogo
            },
            child: const Text("Actualizar"),
          ),
        ],
      );
    },
  );
}

//FUNCION PARA GUARDAR
Future<void> guardarNota(
  String titulo,
  String descripcion,
  double precio,
  String? usuarioId,
) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref("notas/$usuarioId");

  await ref.push().set({
    "titulo": titulo,
    "descripcion": descripcion,
    "precio": precio,
  });
}

//FUNCION PARA BUSCAR DATOS DE UNA NOTA YA EXISTENTE
Future<Object?> buscarNotaEditar(String userId, String notaId) async {
  final ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('/notas/$userId/$notaId').get();
  if (snapshot.exists) {
    return snapshot.value;
  } else {
    return Text("Error al traer esta nota");
  }
}

//FUNCION PARA ACTUALIZAR
Future<void> actualizarNota(
  String userId,
  String notaId,
  String titulo,
  String descripcion,
  double precio,
) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref(
    "notas/$userId/$notaId",
  );

  await ref.update({
    "titulo": titulo,
    "descripcion": descripcion,
    "precio": precio,
  });
  print("Nota actualizada con éxito");
}
