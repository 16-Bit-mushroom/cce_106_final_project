import 'package:flutter/material.dart';
import 'gallery/gallery_screen.dart'; // Your existing gallery screen
// TODO: Create these screens
// import 'albums/albums_screen.dart'; // New empty screen for Albums
// import 'settings/settings_screen.dart'; // New empty screen for Settings

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0; // State for the selected tab

  // List of screens to display in each tab
  final List<Widget> _screens = [
    const GalleryScreen(),
    const AlbumsScreen(), // Will create this
    const SettingsScreen(), // Will create this
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Displays the screen corresponding to the current index
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Albums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Placeholder for AlbumsScreen
class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Your Albums")),
      body: const Center(
        child: Text("Albums content goes here!"),
      ),
    );
  }
}

// Placeholder for SettingsScreen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: const Center(
        child: Text("Settings content goes here!"),
      ),
    );
  }
}