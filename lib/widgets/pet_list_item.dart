import 'package:flutter/material.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/providers/pet_provider.dart';
import 'package:mybestfriend/screens/pet_details_screen.dart';

class PetListItem extends StatelessWidget {
  final Pet pet;
  final PetProvider petProvider;

  const PetListItem({
    super.key,
    required this.pet,
    required this.petProvider,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => PetDetailsScreen(pet: pet),
          ),
        );
      },
      child: Card(
        color: pet.needsHelp ? Colors.red[100] : Colors.lightBlue[100],
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          leading: pet.imageUrl.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(pet.imageUrl),
                )
              : CircleAvatar(
                  child: Text(pet.name[0]),
                ),
          title: Text(
            "${pet.name}, ${pet.age}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: pet.currentLevelExperience / 100.0,
                color: Colors.purple,
              ),
              Text('Level: ${pet.currentLevel}'),
            ],
          ),
        ),
      ),
    );
  }
}
