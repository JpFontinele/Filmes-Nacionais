import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class NewMoviePage extends StatefulWidget {
  const NewMoviePage({super.key});

  @override
  State<NewMoviePage> createState() => _NewMoviePageState();
}

class _NewMoviePageState extends State<NewMoviePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  String? titulo;
  String? diretor;
  String? sinopse;
  File? imagePath;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    loadAssetImage();
    debugPrint("Details iniState Called: $imagePath");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Novo filme"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Título',
              ),
              onSaved: (String? value) {
                if (value == null || value.isEmpty) {
                  titulo = "Título pendente";
                } else {
                  titulo = value;
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Diretor'),
              onSaved: (String? value) {
                if (value == null || value.isEmpty) {
                  diretor = "Diretor pendente";
                } else {
                  diretor = value;
                }
              },
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: 'Sinopse'),
              onSaved: (String? value) {
                if (value == null || value.isEmpty) {
                  sinopse = "Sinopse pendente";
                } else {
                  sinopse = value;
                }
              },
            ),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: InkWell(
                  onTap: imagePicker,
                  child: imageBytes != null
                      ? Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                              image: MemoryImage(imageBytes!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          width: 100,
                          height: 100,
                        )
                      : Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.grey,
                            size: 80,
                          ),
                        ),
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Salvando...')));
                    _formKey.currentState!.save();
                    await postMovie(titulo!, diretor!, sinopse!, imagePath!);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  }
                },
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadAssetImage() async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/claquete.png';
    ByteData assetData = await rootBundle.load('assets/claquete.png');
    File(tempPath).writeAsBytesSync(assetData.buffer.asUint8List());
    // File tempFile = File(tempPath);
    imagePath = File(tempPath);
    debugPrint(imagePath!.path);
  }

  imagePicker() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        this.imageBytes = imageBytes;
      });
      imagePath = File(pickedFile.path);
      debugPrint("Image path: $imagePath");
    }
  }

  postMovie(
      String titulo, String diretor, String sinopse, File imagePath) async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    final ref = storage.ref().child(fileName);
    await ref.putFile(imagePath);

    Map<String, dynamic> movie = {
      "titulo": titulo,
      "diretor": diretor,
      "sinopse": sinopse,
      "image": fileName,
      "liked": false,
    };

    await db.collection("movies").doc(fileName).set(movie);
  }
}
