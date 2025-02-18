import 'package:flutter/material.dart';
import 'package:mybestfriend/widgets/pet_list_item.dart';
import 'package:provider/provider.dart';
import './add_pet_screen.dart';
import '../providers/pet_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);

    return FutureBuilder(
      future: petProvider.loadPets(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Mis Mascotas'),
          ),
          body: petProvider.pets.isEmpty
              ? Center(child: Text('No tienes mascotas aún.'))
              : ListView.builder(
                  itemCount: petProvider.pets.length,
                  itemBuilder: (ctx, index) {
                    final pet = petProvider.pets[index];
                    return PetListItem(pet: pet, petProvider: petProvider);
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => AddPetScreen()),
              );
            },
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}
