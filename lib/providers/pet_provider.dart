import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mybestfriend/extensions/string_extension.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/services/auth_service.dart';
import 'package:mybestfriend/services/notification_service.dart';

class PetProvider extends ChangeNotifier {
  final db = FirebaseFirestore.instance;

  List<Pet> _pets = [];

  List<Pet> get pets => _pets;

  PetProvider() {
    loadPets();
  }

  loadPets() {
    final userId = AuthService().getUserId();
    if (userId == null) return [];
    final docRef = db.collection('pets').where('userId', isEqualTo: userId);
    docRef.orderBy('name').snapshots().listen((event) {
      _pets = event.docs.map((e) => Pet.fromFirestore(e, null)).toList();
      _pets.sort((a, b) {
        // Sort by 'needsHelp' first
        if (a.needsHelp != b.needsHelp) {
          return a.needsHelp ? -1 : 1; // Pets that need help come first
        }
        // If 'needsHelp' is the same, sort by 'name'
        return a.name.compareTo(b.name);
      });
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

  void _schedulePetReminders() {
    for (var pet in _pets) {
      if (pet.feedingTimes.isNotEmpty) {
        for (var time in pet.feedingTimes) {
          DateTime now = DateTime.now();
          DateTime scheduleTime = DateTime(now.year, now.month, now.day,
              time.hour, time.minute); // Convert TimeOfDay to DateTime

          if (scheduleTime.isAfter(now)) {
            NotificationService.scheduleNotification(
              id: pet.id.hashCode + time.hashCode,
              title: "Time to feed ${pet.name}!",
              body: "It's feeding time for ${pet.name}.",
              scheduledTime: scheduleTime,
            );
          }
        }
      }

      if (pet.walkingTimes.isNotEmpty) {
        for (var time in pet.walkingTimes) {
          DateTime now = DateTime.now();
          DateTime scheduleTime = DateTime(now.year, now.month, now.day,
              time.hour, time.minute); // Convert TimeOfDay to DateTime

          if (scheduleTime.isAfter(now)) {
            NotificationService.scheduleNotification(
              id: pet.id.hashCode + time.hashCode + 1,
              title: "Time to walk ${pet.name}!",
              body: "Take ${pet.name} for a walk.",
              scheduledTime: scheduleTime,
            );
          }
        }
      }
    }
  }

  addPet(Pet pet) async {
    pet.feedingTimes.sort(_compareTimeOfDay);
    pet.walkingTimes.sort(_compareTimeOfDay);
    pet.lastWalked = DateTime.now();
    pet.lastFed = DateTime.now();
    pet.experience = 0.0;
    pet.name = pet.name.capitalize();

    await db.collection('pets').add(pet.toFirestore());
    notifyListeners();
    _schedulePetReminders();
  }

  updatePet(Pet pet) async {
    pet.feedingTimes.sort(_compareTimeOfDay);
    pet.walkingTimes.sort(_compareTimeOfDay);
    await db.collection('pets').doc(pet.id).update(pet.toFirestore());
    notifyListeners();
    _schedulePetReminders();
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
