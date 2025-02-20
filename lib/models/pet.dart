import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Pet {
  String? id;
  String userId;
  final String name;
  final DateTime birthday;
  final String imageUrl;
  double experience;
  DateTime lastWalked;
  DateTime lastFed;
  DateTime lastPlayed;
  List<TimeOfDay> feedingTimes;
  List<TimeOfDay> walkingTimes;

  Pet({
    this.id,
    this.userId = "",
    required this.name,
    required this.birthday,
    required this.imageUrl,
    this.experience = 0.0,
    DateTime? lastWalked,
    DateTime? lastFed,
    DateTime? lastPlayed,
    this.feedingTimes = const [],
    this.walkingTimes = const [],
  })  : lastPlayed = lastPlayed ?? DateTime.now().subtract(Duration(days: 1)),
        lastWalked = lastWalked ?? DateTime.now(),
        lastFed = lastFed ?? DateTime.now();

  int get age {
    final currentDate = DateTime.now();
    int age = currentDate.year - birthday.year;

    // Adjust if the birthday hasn't occurred yet this year
    if (currentDate.month < birthday.month ||
        (currentDate.month == birthday.month &&
            currentDate.day < birthday.day)) {
      age--;
    }
    return age;
  }

  get walks => walkingTimes.isNotEmpty;
  get eats => feedingTimes.isNotEmpty;
  get happiness => _calculateHappinessBasedOnPlay();
  get pipi => _calculatePipiNeedBasedOnWalkingTimes();
  get hunger => _calculateHungerBasedOnFeedingTimes();
  get currentLevel => (experience / 50).toInt();
  get currentLevelExperience => ((experience % 50) / 50) * 100;
  get canWalk => _isActionAvailable(lastWalked, walkingTimes);
  get canEat => _isActionAvailable(lastFed, feedingTimes);
  get canPlay => lastPlayed.day < DateTime.now().day;
  get nextWalkTime => _getNextScheduledTime(walkingTimes, DateTime.now());
  get previousWalkTime =>
      _getPreviousScheduledTime(walkingTimes, DateTime.now());
  get nextFeedTime => _getNextScheduledTime(feedingTimes, DateTime.now());
  DateTime? get previousFeedTime =>
      _getPreviousScheduledTime(feedingTimes, DateTime.now());

  void addExperience(int value) {
    experience = experience + value;
  }

  bool _isActionAvailable(DateTime? lastAction, List<TimeOfDay> times) {
    if (lastAction == null || times.isEmpty) return false;

    // Convert all timeofday to datetime
    DateTime now = DateTime.now();
    var todayTimes = [];
    for (final time in times) {
      todayTimes
          .add(DateTime(now.year, now.month, now.day, time.hour, time.minute));
    }

    // Compares if last action is done between times or before that
    for (final todayTime in todayTimes) {
      if (lastAction.isBefore(todayTime) && now.isAfter(todayTime)) return true;
    }
    return false;
  }

  bool _isBefore(time1, time2) {
    return time1.hour < time2.hour ||
        (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  double _calculateHappinessBasedOnPlay() {
    final currentTime = DateTime.now();
    final timeDifference = currentTime.difference(lastPlayed).inMinutes;

    double calculatedHappiness = 100.0;

    calculatedHappiness -= timeDifference / 2880 * 100;
    calculatedHappiness = calculatedHappiness.clamp(0.0, 100.0);

    return calculatedHappiness;
  }

  // Calculate hunger based on the feedingTimes
  double _calculateHungerBasedOnFeedingTimes() {
    if (canEat) return 100.0;

    final currentTime = DateTime.now();
    final nextFeedingTime = _getNextScheduledTime(feedingTimes, currentTime);
    final previousFeedingTime =
        _getPreviousScheduledTime(feedingTimes, currentTime);

    if (_isBefore(lastFed, previousFeedingTime)) {
      return 100.0;
    }

    if (nextFeedingTime == null) {
      return 0.0; // No upcoming feeding times, no hunger for now
    }

    final timeSinceLastFed = currentTime.difference(lastFed).inMinutes;
    final timeUntilNextFeeding =
        nextFeedingTime.difference(currentTime).inMinutes;

    double hungerValue = 0.0;

    if (timeUntilNextFeeding <= 0) {
      hungerValue =
          100.0; // If the time has already passed for feeding, hunger is at max
    } else {
      hungerValue =
          ((timeSinceLastFed) / (timeSinceLastFed + timeUntilNextFeeding)) *
              100;
    }

    return hungerValue.clamp(0.0, 100.0);
  }

  // Calculate walk need based on the walkingTimes
  double _calculatePipiNeedBasedOnWalkingTimes() {
    if (canWalk) return 100.0;

    final currentTime = DateTime.now();
    final nextWalkingTime = _getNextScheduledTime(walkingTimes, currentTime);
    final previousWalkingTime =
        _getPreviousScheduledTime(walkingTimes, currentTime);

    if (_isBefore(lastWalked, previousWalkingTime)) {
      return 100.0;
    }

    if (nextWalkingTime == null) {
      return 0.0; // No upcoming walking times, no pipi need for now
    }

    final timeSinceLastWalked = currentTime.difference(lastWalked).inMinutes;
    final timeUntilNextWalk = nextWalkingTime.difference(currentTime).inMinutes;

    double pipiValue = 0.0;

    if (timeUntilNextWalk <= 0) {
      pipiValue =
          100.0; // If the time has already passed for the walk, pipi need is at max
    } else {
      pipiValue =
          ((timeSinceLastWalked) / (timeSinceLastWalked + timeUntilNextWalk)) *
              100;
    }

    return pipiValue.clamp(0.0, 100.0);
  }

  // Helper method to get the next scheduled feeding or walking time
  DateTime? _getNextScheduledTime(
      List<TimeOfDay> times, DateTime currentDateTime) {
    if (times.isEmpty) return null;

    for (var time in times) {
      final scheduledTime = DateTime(currentDateTime.year,
          currentDateTime.month, currentDateTime.day, time.hour, time.minute);

      if (scheduledTime.isAfter(currentDateTime)) {
        return scheduledTime;
      }
    }

    // If no future times are found, check for the next day
    final nextDay = currentDateTime.add(Duration(days: 1));
    final firstTimeOfNextDay = times.first;
    return DateTime(nextDay.year, nextDay.month, nextDay.day,
        firstTimeOfNextDay.hour, firstTimeOfNextDay.minute);
  }

  DateTime? _getPreviousScheduledTime(
      List<TimeOfDay> times, DateTime currentDateTime) {
    if (times.isEmpty) return null;

    DateTime previousScheduledTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        times[times.length - 1].hour,
        times[times.length - 1].minute);
    for (var time in times) {
      final scheduledTime = DateTime(currentDateTime.year,
          currentDateTime.month, currentDateTime.day, time.hour, time.minute);

      if (scheduledTime.isAfter(currentDateTime)) {
        return previousScheduledTime;
      }
      previousScheduledTime = scheduledTime;
    }

    // If no previous times are found, returns from last day
    final previousDay = currentDateTime.subtract(Duration(days: 1));
    final lastTimeOfNextDay = times.last;
    return DateTime(previousDay.year, previousDay.month, previousDay.day,
        lastTimeOfNextDay.hour, lastTimeOfNextDay.minute);
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
        lastPlayed: DateTime.now(),
        lastWalked: DateTime.now(),
        lastFed: DateTime.now(),
        feedingTimes: [],
        walkingTimes: [],
      );
    }
    return Pet(
      id: snapshot.id,
      userId: data['userId'] ?? "",
      name: data['name'] ?? "",
      birthday: (data['birthday'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] ?? "",
      experience: (data['experience'] ?? 0.0).toDouble(),
      lastPlayed:
          (data['lastPlayed'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      'userId': userId,
      'name': name,
      'birthday': birthday,
      'imageUrl': imageUrl,
      'experience': experience,
      'lastPlayed': lastPlayed,
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
