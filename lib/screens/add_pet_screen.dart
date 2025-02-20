import 'package:flutter/material.dart';
import 'package:mybestfriend/widgets/pet_form.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';

class AddPetScreen extends StatelessWidget {
  const AddPetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: PetForm(
        onSave: (pet) {
          Provider.of<PetProvider>(context, listen: false).addPet(pet);
        },
      ),
    );
  }
}
