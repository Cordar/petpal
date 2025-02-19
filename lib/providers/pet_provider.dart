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

  addPet(String name, DateTime birthday, String imageUrl,
      List<TimeOfDay> feedingTimes, List<TimeOfDay> walkingTimes) async {
    var pet = Pet(
      name: name,
      birthday: birthday,
      imageUrl: imageUrl,
      experience: 0.0,
      happiness: 100.0,
      hunger: 0.0,
      lastWalked: DateTime.now(),
      lastFed: DateTime.now(),
      feedingTimes: feedingTimes, // Default feeding times
      walkingTimes: walkingTimes, // Default walking times
    );

    await db.collection('pets').add(pet.toFirestore());
    notifyListeners();
  }

  void startWalk(Pet pet) {
    pet.lastWalked = DateTime.now();
    pet.happiness = (pet.happiness + 10).clamp(0, 100);
    pet.experience += 10;

    db.collection('pets').doc(pet.id).update({
      'lastWalked': pet.lastWalked,
      'happiness': pet.happiness,
      'experience': pet.experience,
    });

    notifyListeners();
  }

  void giveFood(Pet pet) {
    pet.lastFed = DateTime.now();
    pet.hunger = (pet.hunger + 20).clamp(0, 100);
    pet.happiness = (pet.happiness + 5).clamp(0, 100);
    pet.experience += 1;

    db.collection('pets').doc(pet.id).update({
      'lastFed': pet.lastFed,
      'hunger': pet.hunger,
      'happiness': pet.happiness,
      'experience': pet.experience,
    });

    notifyListeners();
  }
}
