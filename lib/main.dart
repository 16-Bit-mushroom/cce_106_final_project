import 'package:cce_106_final_project/views/root_screen.dart';
import 'package:flutter/material.dart';
// import 'views/gallery/gallery_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Styler App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto', // Or any font you prefer
      ),
      debugShowCheckedModeBanner: false,
      home: const RootScreen(),
    );
  }
}