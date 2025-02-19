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

  loadPet(String name) {
    return pets.firstWhere((element) => element.name == name);
  }

  addPet(String name, DateTime birthday, String imageUrl,
      List<TimeOfDay> feedingTimes, List<TimeOfDay> walkingTimes) async {
    feedingTimes.sort(_compareTimeOfDay);
    walkingTimes.sort(_compareTimeOfDay);
    var pet = Pet(
      name: name,
      birthday: birthday,
      imageUrl: imageUrl,
      experience: 0.0,
      lastWalked: DateTime.now(),
      lastFed: DateTime.now(),
      feedingTimes: feedingTimes,
      walkingTimes: walkingTimes,
    );

    await db.collection('pets').add(pet.toFirestore());
    notifyListeners();
  }

  void walk(Pet pet) {
    if (!pet.canWalk) return;
    pet.lastWalked = DateTime.now();
    pet.experience += 10;

    db.collection('pets').doc(pet.id).update({
      'lastWalked': pet.lastWalked,
      'experience': pet.experience,
    });

    notifyListeners();
  }

  void feed(Pet pet) {
    if (!pet.canEat) return;
    pet.lastFed = DateTime.now();
    pet.experience += 5;

    db.collection('pets').doc(pet.id).update({
      'lastFed': pet.lastFed,
      'experience': pet.experience,
    });

    notifyListeners();
  }

  void play(Pet pet) {
    if (!pet.canPlay) return;
    pet.lastPlayed = DateTime.now();
    pet.experience += 20;

    db.collection('pets').doc(pet.id).update({
      'lastPlayed': pet.lastPlayed,
      'experience': pet.experience,
    });

    notifyListeners();
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour == b.hour) {
      return a.minute.compareTo(b.minute);
    }
    return a.hour.compareTo(b.hour);
  }
}
