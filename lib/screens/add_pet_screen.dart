import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pet_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  _AddPetScreenState createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _ageController = TextEditingController();
  File? _selectedImage;
  Uint8List? _compressedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      // Further compress the image
      final compressed = await _compressImage(File(pickedImage.path));
      setState(() {
        _selectedImage = File(pickedImage.path);
        _compressedImage = compressed;
      });
    }
  }

  Future<Uint8List> _compressImage(File file) async {
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 50,
    );
    if (result == null) {
      return Uint8List(0); // Return empty Uint8List if compression fails
    }
    return result;
  }

  Future<void> _savePet() async {
    final name = _nameController.text;
    final type = _typeController.text;
    final age = int.tryParse(_ageController.text) ?? 0;

    if (name.isEmpty || type.isEmpty || age <= 0 || _compressedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    // Encode image as base64
    final imageBase64 = base64Encode(_compressedImage!);

    Provider.of<PetProvider>(context, listen: false)
        .addPet(name, type, age, imageBase64);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _typeController,
              decoration: InputDecoration(labelText: 'Raza'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Edad'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    _selectedImage != null ? FileImage(_selectedImage!) : null,
                child: _selectedImage == null
                    ? Icon(Icons.add_a_photo, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            _isUploading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePet,
                    child: Text('Guardar'),
                  ),
          ],
        ),
      ),
    );
  }
}
