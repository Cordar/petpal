import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybestfriend/models/pet.dart';

class PetProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  List<Pet> pets = [];

  PetProvider() {
    loadPets();
  }

  loadPets() {
    final docRef = db.collection('pets');
    docRef.orderBy('name').snapshots().listen((event) {
      pets = event.docs.map((e) => Pet.fromFirestore(e, null)).toList();
      notifyListeners();
    });
  }

  addPet(String name, String type, int age, String? imageBase64) async {
    var pet = Pet(
      name: name,
      type: type,
      age: age,
      imageBase64: imageBase64 ?? "",
      experience: 0,
      happiness: 50,
    );

    await db.collection('pets').add(pet.toFirestore());
    notifyListeners();
  }

  void startWalk(Pet pet) {
    // Update pet state and notify listeners
  }

  void giveFood(Pet pet) {
    // Update pet state and notify listeners
  }
}
