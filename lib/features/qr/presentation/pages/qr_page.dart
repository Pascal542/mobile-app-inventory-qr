import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class QRPage extends StatefulWidget {
  const QRPage({super.key});
  
  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  File? _image;
  final String _imageKey = 'saved_qr_image';

  @override
  void initState() {
    super.initState();
    _loadImageFromPrefs();
  }

  Future<void> _loadImageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString(_imageKey);

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = pickedFile.name;
      final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageKey, savedImage.path);

      setState(() {
        _image = savedImage;
      });
    }
  }

  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imageKey);
    setState(() {
      _image = null;
    });
  }

  Future<void> _uploadToFirebase() async {
    if (_image == null) return;

    try {
      

      // Crear instancia de FirebaseStorage con tu bucket personalizado
      final firebaseStorage = FirebaseStorage.instanceFor(
        bucket: 'gs://vendify-qr', // ✅ Tu bucket personalizado
      );

      final fileName = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef = firebaseStorage.ref().child('qrs/$fileName');

      // Subir imagen
      final uploadTask = storageRef.putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() {});

      // Obtener URL descargable
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (!mounted) return;

      // Mostrar URL en un SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ QR subido con éxito:\n$downloadUrl'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al subir QR: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Pago'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Tu Código QR de Pago',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              _image != null
                  ? 'Este es tu QR cargado para recibir pagos.'
                  : 'Aún no has cargado un código QR. Puedes seleccionar uno de tu galería.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  _image != null
                      ? Image.file(
                          _image!,
                          height: 250,
                          width: 250,
                          fit: BoxFit.cover,
                        )
                      : const Column(
                          children: [
                            Icon(Icons.qr_code_2, size: 100, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'Sin QR cargado',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_search),
                    label: const Text('Seleccionar Imagen QR'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_image != null)
                    OutlinedButton.icon(
                      onPressed: _removeImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar QR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  const SizedBox(height: 12),
                  if (_image != null)
                    ElevatedButton.icon(
                      onPressed: _uploadToFirebase,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Subir QR a Firebase'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
