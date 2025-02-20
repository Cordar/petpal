import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/providers/pet_provider.dart';
import 'package:mybestfriend/widgets/action_button.dart';
import 'package:mybestfriend/widgets/stat_bar.dart';
import 'package:mybestfriend/screens/edit_pet_screen.dart';
import 'package:provider/provider.dart';

class PetDetailsScreen extends StatefulWidget {
  final Pet pet;

  const PetDetailsScreen({super.key, required this.pet});

  @override
  PetDetailsScreenState createState() => PetDetailsScreenState();
}

class PetDetailsScreenState extends State<PetDetailsScreen> {
  late Pet pet;

  @override
  void initState() {
    super.initState();
    pet = widget.pet;
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(pet.imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              "${pet.name}, ${pet.age}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StatBar(
                label: "Experience (${pet.currentLevel})",
                colorMin: Colors.purple,
                colorMax: Colors.purple,
                value: pet.experience,
                maxValue: 50.0),
            if (pet.canEat)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: StatBar(
                            label: "Hunger",
                            previousTime: pet.lastFed,
                            nextTime: pet.nextFeedTime,
                            colorMin: Colors.green,
                            colorMax: Colors.red,
                            value: pet.hunger,
                            maxValue: 100.0),
                      ),
                      SizedBox(width: 20), // Add spacing between the buttons
                      Expanded(
                        child: ActionButton(
                          label: pet.previousFeedTime != null
                              ? pet.canEat
                                  ? DateFormat('HH:mm')
                                      .format(pet.previousFeedTime!)
                                      .toString()
                                  : DateFormat('HH:mm')
                                      .format(pet.nextFeedTime!)
                                      .toString()
                              : "Feed",
                          color: Colors.orange,
                          icon: Icons.restaurant,
                          onPressed: () {
                            petProvider.feed(pet);
                          },
                          isDisabled: !pet.canEat,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (pet.canWalk)
              Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: StatBar(
                            label: "Pipi",
                            previousTime: pet.lastWalked,
                            nextTime: pet.nextWalkTime,
                            colorMin: Colors.green,
                            colorMax: Colors.red,
                            value: pet.pipi,
                            maxValue: 100.0),
                      ),
                      SizedBox(width: 20), // Add spacing between the buttons
                      Expanded(
                        child: ActionButton(
                          label: pet.previousWalkTime != null
                              ? pet.canWalk
                                  ? DateFormat('HH:mm')
                                      .format(pet.previousWalkTime!)
                                      .toString()
                                  : DateFormat('HH:mm')
                                      .format(pet.nextWalkTime!)
                                      .toString()
                              : "Walk",
                          color: Colors.blue,
                          icon: Icons.directions_walk,
                          onPressed: () {
                            petProvider.walk(pet);
                          },
                          isDisabled: !pet.canWalk,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: StatBar(
                      label: "Happiness",
                      previousTime: pet.lastPlayed,
                      colorMin: Colors.red,
                      colorMax: Colors.green,
                      value: pet.happiness,
                      maxValue: 100.0),
                ),
                SizedBox(width: 20), // Add spacing between the buttons
                Expanded(
                  child: ActionButton(
                    label: "Play",
                    color: Colors.purple,
                    icon: Icons.sports_baseball_rounded,
                    onPressed: () {
                      petProvider.play(pet);
                    },
                    isDisabled: !pet.canPlay,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
