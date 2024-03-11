import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditPage extends StatefulWidget {
  final Map<String, dynamic> movie;

  const EditPage({super.key, required this.movie});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  File? imagePath;
  Uint8List? imageBytes;

  late String titulo;
  late String diretor;
  late String sinopse;
  late String idDoc = '';
  late Uint8List image;

  @override
  void initState() {
    super.initState();
    loadAssetImage();
    titulo = widget.movie["titulo"];
    diretor = widget.movie["diretor"];
    sinopse = widget.movie["sinopse"];
    idDoc = widget.movie["id"];
    image = widget.movie["image"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Editar Filme"),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              initialValue: titulo,
              decoration: const InputDecoration(labelText: "Título"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um título válido';
                }
                return null;
              },
              onSaved: (value) => titulo = value!,
            ),
            TextFormField(
              initialValue: diretor,
              decoration: const InputDecoration(labelText: "Diretor"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um diretor válido';
                }
                return null;
              },
              onSaved: (value) => diretor = value!,
            ),
            TextFormField(
              initialValue: sinopse,
              maxLines: null,
              decoration: const InputDecoration(labelText: "Sinopse"),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma sinopse válida';
                }
                return null;
              },
              onSaved: (value) => sinopse = value!,
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
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  editMovie(idDoc, titulo, diretor, sinopse, imagePath!);

                  Navigator.pop(context, true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadAssetImage() async {
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/claquete.png';
    final ByteData assetData = await rootBundle.load('assets/claquete.png');
    File(tempPath).writeAsBytesSync(assetData.buffer.asUint8List());
    imagePath = File(tempPath);
    imageBytes = File(tempPath).readAsBytesSync();
  }

  Future<void> imagePicker() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();
      setState(() {
        imageBytes = bytes;
      });
      imagePath = File(pickedFile.path);
    }
  }

  editMovie(String idDoc, String titulo, String diretor, String sinopse, File imagePath) async {

    final ref = storage.ref().child(idDoc);
    await ref.putFile(imagePath);

    Map<String, dynamic> movie = {
      "titulo": titulo,
      "diretor": diretor,
      "sinopse": sinopse,
      "image": idDoc,
      "user_id": FirebaseAuth.instance.currentUser!.uid,
      "user_email": FirebaseAuth.instance.currentUser!.email,
    };

    await db.collection("movies").doc(idDoc).set(movie);

  }

}
