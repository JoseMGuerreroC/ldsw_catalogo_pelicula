import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  final _directorCtrl = TextEditingController();
  final _generoCtrl = TextEditingController();
  final _sinopsisCtrl = TextEditingController();
  final _imagenCtrl = TextEditingController();

  final _moviesRef = FirebaseFirestore.instance.collection('peliculas');

  Future<void> _agregarPelicula() async {
    if (!_formKey.currentState!.validate()) return;

    await _moviesRef.add({
      'titulo': _tituloCtrl.text.trim(),
      'anio': _anioCtrl.text.trim(),
      'director': _directorCtrl.text.trim(),
      'genero': _generoCtrl.text.trim(),
      'sinopsis': _sinopsisCtrl.text.trim(),
      'imagenUrl': _imagenCtrl.text.trim(),
    });

    _tituloCtrl.clear();
    _anioCtrl.clear();
    _directorCtrl.clear();
    _generoCtrl.clear();
    _sinopsisCtrl.clear();
    _imagenCtrl.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Película agregada al catálogo')),
    );
  }

  Future<void> _eliminarPelicula(String id) async {
    await _moviesRef.doc(id).delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Película dada de baja')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración de Catálogo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alta de Nueva Película',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tituloCtrl,
                    decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa el título' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _anioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Año de estreno', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa el año' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _directorCtrl,
                    decoration: const InputDecoration(labelText: 'Director', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa el director' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _generoCtrl,
                    decoration: const InputDecoration(labelText: 'Género cinematográfico', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa el género' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _sinopsisCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Sinopsis', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa la sinopsis' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _imagenCtrl,
                    decoration: const InputDecoration(labelText: 'URL de la imagen / póster', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Ingresa la URL de la imagen' : null,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _agregarPelicula,
                      icon: const Icon(Icons.add),
                      label: const Text('Guardar Película'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 40),
            const Text(
              'Baja de Películas Existentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _moviesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No hay películas registradas.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final movie = Movie.fromMap(
                      docs[index].id,
                      docs[index].data() as Map<String, dynamic>,
                    );
                    return Card(
                      child: ListTile(
                        leading: Image.network(
                          movie.imagenUrl,
                          width: 45,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.movie),
                        ),
                        title: Text(movie.titulo),
                        subtitle: Text('${movie.anio} • ${movie.director}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarPelicula(movie.id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}