import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:summerclass/splash_page.dart';
import 'details_page.dart';
import 'firebase_options.dart';
import 'new_movie_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Summerclass',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashPage(),
      routes: {
        "/new": (context) =>const NewMoviePage(),
        "/details": (context) =>const DetailsPage(),

      },
    );
  }
}


