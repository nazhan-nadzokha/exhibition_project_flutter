import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Guest.dart';


Future<void> main() async {
  // 1. Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase BEFORE anything else
  await Firebase.initializeApp();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      home: GuestPage(),
    );
  }
}