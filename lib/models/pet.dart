import 'package:cloud_firestore/cloud_firestore.dart';

class Pet {
  final String name;
  final String type;
  final int age;
  final String imageBase64;
  int experience;
  double happiness;

  Pet({
    required this.name,
    required this.type,
    required this.age,
    required this.imageBase64,
    this.experience = 0,
    this.happiness = 100.0,
  });

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
          age: 0,
          name: "unknown",
          type: "unknown",
          imageBase64: "",
          experience: 0,
          happiness: 0);
    }
    return Pet(
        name: data['name'] ?? "",
        type: data['type'] ?? "",
        age: data['age'] ?? "",
        imageBase64: data['imageBase64'] ?? "",
        experience: data['experience'] ?? "",
        happiness: data['happiness'] == null
            ? 0.0
            : data['happiness'].toDouble() ?? "");
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'age': age,
      'imageBase64': imageBase64,
      'experience': experience,
      'happiness': happiness,
    };
  }
}
