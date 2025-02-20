import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/services/auth_service.dart';

class PetProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  List<Pet> pets = [];

  PetProvider() {
    loadPets();
  }

  loadPets() {
    final userId = AuthService().getUserId();
    if (userId == null) return [];
    final docRef = db.collection('pets').where('userId', isEqualTo: userId);
    docRef.orderBy('name').snapshots().listen((event) {
      pets = event.docs.map((e) => Pet.fromFirestore(e, null)).toList();
      notifyListeners();
    });
  }

  Future<Pet?> loadPet(String name) async {
    final userId = AuthService().getUserId();
    if (userId == null) return null;

    final querySnapshot = await db
        .collection('pets')
        .where('userId', isEqualTo: userId)
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return Pet.fromFirestore(querySnapshot.docs.first, null);
    }
    return null; // Return null if the pet is not found
  }

  addPet(Pet pet) async {
    pet.feedingTimes.sort(_compareTimeOfDay);
    pet.walkingTimes.sort(_compareTimeOfDay);
    pet.lastWalked = DateTime.now();
    pet.lastFed = DateTime.now();
    pet.experience = 0.0;
    pet.userId = AuthService().getUserId() ?? "no user";

    await db.collection('pets').add(pet.toFirestore());
    notifyListeners();
  }

  updatePet(Pet pet) async {
    pet.feedingTimes.sort(_compareTimeOfDay);
    pet.walkingTimes.sort(_compareTimeOfDay);
    await db.collection('pets').doc(pet.id).update({
      'name': pet.name,
      'birthday': pet.birthday,
      'feedingTimes': pet.feedingTimes,
      'walkingTimes': pet.walkingTimes,
    });
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
