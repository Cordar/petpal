import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/pet_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  AddPetScreenState createState() => AddPetScreenState();
}

class AddPetScreenState extends State<AddPetScreen> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  DateTime? _selectedBirthday;
  final List<TimeOfDay> _feedingTimes = [];
  final List<TimeOfDay> _walkingTimes = [];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _pickBirthday() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedBirthday = pickedDate;
        _birthdayController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _pickTime(List<TimeOfDay> timeList) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeList.add(pickedTime);
      });
    }
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final fileName = DateTime.now().toString();
      final ref =
          FirebaseStorage.instance.ref().child('pet_images/$fileName.jpg');

      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePet() async {
    final name = _nameController.text;

    if (name.isEmpty || _selectedBirthday == null || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final imageUrl = await _uploadImageToFirebase(_selectedImage!);

    setState(() {
      _isUploading = false;
    });

    if (imageUrl != null) {
      Provider.of<PetProvider>(context, listen: false).addPet(
        name,
        _selectedBirthday!,
        imageUrl,
        _feedingTimes,
        _walkingTimes,
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Mascota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _birthdayController,
                readOnly: true,
                onTap: _pickBirthday,
                decoration: const InputDecoration(labelText: 'Cumpleaños'),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : null,
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Feeding Times:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._feedingTimes.map(
                (time) => Text(time.format(context)),
              ),
              TextButton(
                onPressed: () => _pickTime(_feedingTimes),
                child: const Text('Add Feeding Time'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Walking Times:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ..._walkingTimes.map(
                (time) => Text(time.format(context)),
              ),
              TextButton(
                onPressed: () => _pickTime(_walkingTimes),
                child: const Text('Add Walking Time'),
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _savePet,
                      child: const Text('Guardar'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
