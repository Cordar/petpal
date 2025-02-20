import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mybestfriend/services/time_service.dart';
import '../models/pet.dart';

class PetForm extends StatefulWidget {
  final Pet? pet; // If null, we are adding a new pet
  final void Function(Pet pet) onSave;

  const PetForm({super.key, this.pet, required this.onSave});

  @override
  PetFormState createState() => PetFormState();
}

class PetFormState extends State<PetForm> {
  final _nameController = TextEditingController();
  final _birthdayController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  DateTime? _selectedBirthday;
  final List<TimeOfDay> _feedingTimes = [];
  final List<TimeOfDay> _walkingTimes = [];

  @override
  void initState() {
    super.initState();
    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _selectedBirthday = widget.pet!.birthday;
      _birthdayController.text =
          "${widget.pet!.birthday.toLocal()}".split(' ')[0];
      _feedingTimes.addAll(widget.pet!.feedingTimes);
      _walkingTimes.addAll(widget.pet!.walkingTimes);
    }
  }

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
      initialDate: _selectedBirthday ?? DateTime.now(),
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

  void _removeTime(List<TimeOfDay> timeList, int index) {
    setState(() {
      timeList.removeAt(index);
    });
  }

  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      final fileName = DateTime.now().toString();
      final ref =
          FirebaseStorage.instance.ref().child('pet_images/$fileName.jpg');

      await ref.putFile(image);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _savePet() async {
    final name = _nameController.text;

    if (name.isEmpty || _selectedBirthday == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, rellena todos los campos.')),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl = widget.pet?.imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToFirebase(_selectedImage!);
    }

    setState(() => _isUploading = false);

    if (imageUrl != null) {
      final updatedPet = Pet(
          id: widget.pet?.id ?? '',
          name: name,
          birthday: _selectedBirthday!,
          imageUrl: imageUrl,
          feedingTimes: _feedingTimes,
          walkingTimes: _walkingTimes,
          experience: widget.pet?.experience ?? 0,
          lastFed: widget.pet?.lastFed ??
              DateTime.now().subtract(const Duration(days: 1)),
          lastWalked: widget.pet?.lastWalked ??
              DateTime.now().subtract(const Duration(days: 1)),
          lastPlayed: widget.pet?.lastPlayed ??
              DateTime.now().subtract(const Duration(days: 1)));

      widget.onSave(updatedPet);
      if (mounted) Navigator.of(context).pop(updatedPet);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al subir la imagen.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
                  : (widget.pet?.imageUrl != null
                      ? NetworkImage(widget.pet!.imageUrl)
                      : null) as ImageProvider?,
              child: _selectedImage == null && widget.pet?.imageUrl == null
                  ? const Icon(Icons.add_a_photo, size: 50)
                  : null,
            ),
          ),
          const SizedBox(height: 20),

          /// Feeding Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Feeding Times:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.green),
                onPressed: () => _pickTime(_feedingTimes),
              ),
            ],
          ),
          ..._feedingTimes.asMap().entries.map((entry) {
            int index = entry.key;
            TimeOfDay time = entry.value;
            return ListTile(
              title: Text(TimeService.formatTime(time)),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeTime(_feedingTimes, index),
              ),
            );
          }),

          /// Walking Times
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Walking Times:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.blue),
                onPressed: () => _pickTime(_walkingTimes),
              ),
            ],
          ),
          ..._walkingTimes.asMap().entries.map((entry) {
            int index = entry.key;
            TimeOfDay time = entry.value;
            return ListTile(
              title: Text(TimeService.formatTime(time)),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeTime(_walkingTimes, index),
              ),
            );
          }),

          const SizedBox(height: 20),
          _isUploading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _savePet,
                  child: const Text('Guardar'),
                ),
        ],
      ),
    );
  }
}
