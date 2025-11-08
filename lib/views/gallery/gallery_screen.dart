import 'package:flutter/material.dart';
import '../components/add_new_style.dart';
import '../components/gallery_header.dart';
import '../components/style_grid.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // int _currentIndex = 0; // REMOVE this - it's handled by RootScreen now

  @override
  Widget build(BuildContext context) {
    // Wrap your existing content in a Scaffold (if not already)
    return Scaffold(
      // AppBar can be here, specific to this tab's content
      // appBar: AppBar(title: const Text("Your Creations")), 
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              GalleryHeader(),
              SizedBox(height: 24),
              Expanded(
                child: StyleGrid(),
              ),
              SizedBox(height: 24),
              AddNewStyleCard(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      // REMOVE bottomNavigationBar here. It's now in RootScreen.
    );
  }
}