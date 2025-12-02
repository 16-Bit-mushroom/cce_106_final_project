import 'package:flutter/material.dart';
import 'package:cce_106_final_project/views/gallery/gallery_screen.dart'; // This is now "Requests/Home"
import 'package:cce_106_final_project/views/selection/image_selection.dart';
import 'package:cce_106_final_project/views/albums/album_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/login_screen.dart';

// --- Placeholder Screens ---
class PhotosTabScreen extends StatelessWidget {
  const PhotosTabScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("All Photos Grid")));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
          child: const Text("Log Out"),
        ),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  static const double kMaxWidth = 800.0;

  final List<Widget> _screens = [
    const GalleryScreen(), // Tab 0: Requests / Dashboard
    const AlbumsScreen(), // Tab 1: Albums
    const PhotosTabScreen(), // Tab 2: Photos
    const ProfileScreen(), // Tab 3: Profile (Avatar)
  ];

  void _onAddPhotoTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImageSelectionScreen()),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Use IndexedStack to keep state alive
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ),
      ),

      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: SafeArea(
            child: Container(
              height: 70, // Slightly more compact
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Tab 0: Requests (Dashboard)
                  _NavBarIcon(
                    icon: Icons.dashboard_outlined,
                    label: "Requests",
                    isSelected: _currentIndex == 0,
                    onTap: () => _onTabTapped(0),
                  ),

                  // Tab 1: Albums
                  _NavBarIcon(
                    icon: Icons.photo_library_outlined,
                    label: "Albums",
                    isSelected: _currentIndex == 1,
                    onTap: () => _onTabTapped(1),
                  ),

                  // CENTER BUTTON: Add / Send Photos
                  GestureDetector(
                    onTap: _onAddPhotoTapped,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF8B553,
                        ), // Matches the yellow/orange in wireframe
                        shape: BoxShape
                            .rectangle, // Wireframe has rounded square [cite: 106]
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF8B553).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  // Tab 2: Photos
                  _NavBarIcon(
                    icon: Icons.image_outlined,
                    label: "Photos",
                    isSelected: _currentIndex == 2,
                    onTap: () => _onTabTapped(2),
                  ),

                  // Tab 3: Profile
                  _NavBarIcon(
                    icon: Icons.person_outline,
                    label: "Profile",
                    isSelected: _currentIndex == 3,
                    onTap: () => _onTabTapped(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? Colors.black87 : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
