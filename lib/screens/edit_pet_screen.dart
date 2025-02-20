import 'package:flutter/material.dart';
import 'package:mybestfriend/models/pet.dart';
import 'package:mybestfriend/providers/pet_provider.dart';
import 'package:mybestfriend/widgets/pet_form.dart';
import 'package:provider/provider.dart';

class EditPetScreen extends StatelessWidget {
  final Pet pet;

  const EditPetScreen({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${pet.name}')),
      body: PetForm(
        pet: pet,
        onSave: (updatedPet) {
          Provider.of<PetProvider>(context, listen: false)
              .updatePet(updatedPet);
        },
      ),
    );
  }
}
