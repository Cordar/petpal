import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mybestfriend/screens/login_screen.dart';
import 'package:provider/provider.dart';
import './providers/pet_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => PetProvider(),
      child: MaterialApp(
        title: 'Pet Pal',
        theme: ThemeData(),
        home: LoginScreen(),
      ),
    );
  }
}
