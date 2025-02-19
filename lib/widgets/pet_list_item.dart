import 'package:flutter/material.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/providers/pet_provider.dart';

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
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: pet.imageUrl.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(pet.imageUrl),
              )
            : CircleAvatar(
                child: Text(pet.name[0]),
              ),
        title: Text(
          pet.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: pet.happinessPercentatge, color: Color.lerp(Colors.red, Colors.green, pet.happinessPercentatge)),
            Text('Exp: ${pet.experience}'),
          ],
        ),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: Icon(Icons.directions_walk),
              color: Colors.blue,
              onPressed: () {
                petProvider.startWalk(pet);
              },
            ),
            IconButton(
              icon: Icon(Icons.pets),
              color: Colors.green,
              onPressed: () {
                petProvider.giveFood(pet);
              },
            ),
          ],
        ),
      ),
    );
  }
}
