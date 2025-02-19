import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Pet {
  String? id;
  final String name;
  final DateTime birthday;
  final String imageUrl;
  double experience;
  double happiness;
  double hunger;
  DateTime lastWalked;
  DateTime lastFed;
  List<TimeOfDay> feedingTimes;
  List<TimeOfDay> walkingTimes;

  Pet({
    this.id,
    required this.name,
    required this.birthday,
    required this.imageUrl,
    this.experience = 0.0,
    this.happiness = 100.0,
    this.hunger = 0.0,
    DateTime? lastWalked,
    DateTime? lastFed,
    this.feedingTimes = const [],
    this.walkingTimes = const [],
  })  : lastWalked = lastWalked ?? DateTime.now(),
        lastFed = lastFed ?? DateTime.now();

  get happinessPercentatge => happiness / 100.0;

  void updateHappiness(double value) {
    happiness = (happiness + value).clamp(0.0, 100.0);
  }

  void addExperience(int value) {
    experience = experience + value;
  }

  factory Pet.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) {
      return Pet(
        id: "id",
        name: "unknown",
        birthday: DateTime.now(),
        imageUrl: "",
        experience: 0.0,
        happiness: 0.0,
        hunger: 50.0,
        lastWalked: DateTime.now(),
        lastFed: DateTime.now(),
        feedingTimes: [],
        walkingTimes: [],
      );
    }
    return Pet(
      id: snapshot.id,
      name: data['name'] ?? "",
      birthday: (data['birthday'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] ?? "",
      experience: (data['experience'] ?? 0.0).toDouble(),
      happiness: (data['happiness'] ?? 0.0).toDouble(),
      hunger: (data['hunger'] ?? 50.0).toDouble(),
      lastWalked:
          (data['lastWalked'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastFed: (data['lastFed'] as Timestamp?)?.toDate() ?? DateTime.now(),
      feedingTimes: (data['feedingTimes'] as List<dynamic>?)
              ?.map((time) => _parseTimeOfDay(time as String))
              .toList() ??
          [],
      walkingTimes: (data['walkingTimes'] as List<dynamic>?)
              ?.map((time) => _parseTimeOfDay(time as String))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthday': birthday,
      'imageUrl': imageUrl,
      'experience': experience,
      'happiness': happiness,
      'hunger': hunger,
      'lastWalked': lastWalked,
      'lastFed': lastFed,
      'feedingTimes':
          feedingTimes.map((time) => _formatTimeOfDay(time)).toList(),
      'walkingTimes':
          walkingTimes.map((time) => _formatTimeOfDay(time)).toList(),
    };
  }

  static String _formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }
}
