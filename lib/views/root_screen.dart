import 'dart:ui'; // Required for ImageFilter
import 'package:flutter/material.dart';
import 'package:cce_106_final_project/views/gallery/gallery_screen.dart';
import 'package:cce_106_final_project/views/selection/image_selection.dart';
import 'package:cce_106_final_project/views/admin/admin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ADD IMPORT HERE:
import 'package:cce_106_final_project/views/gallery/styled_photos_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  String _userRole = 'user';
  bool _loadingRole = true;
  static const double kMaxWidth = 800.0;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9); // Rose Quartz
  final Color color5 = const Color(0xFF92a8d1); // Serenity

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  Future<void> _fetchUserRole() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .single();

      if (mounted) {
        setState(() {
          _userRole = data['role'] ?? 'user';
          _loadingRole = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loadingRole = false);
    }
  }

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
    if (_loadingRole) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF92a8d1))),
      );
    }

    // UPDATED SCREENS LIST
    final List<Widget> screens = [
      const GalleryScreen(),        // Index 0: Queue
      const StyledPhotosScreen(),   // Index 1: New Photos Screen
      AdminScreen(currentUserRole: _userRole), // Index 2: Profile/Admin
    ];

    return Scaffold(
      extendBody: true, // Key for glassmorphism
      backgroundColor: Colors.grey[50],
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: IndexedStack(index: _currentIndex, children: screens),
        ),
      ),
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8), // Milky Glass
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color5.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tab 1: Requests Queue
                      _NavBarIcon(
                        icon: Icons.dashboard_rounded,
                        label: "Queue",
                        isSelected: _currentIndex == 0,
                        onTap: () => _onTabTapped(0),
                        activeColor: color5,
                      ),

                      // NEW Tab 2: Styled Photos
                      _NavBarIcon(
                        icon: Icons.photo_library_rounded,
                        label: "Photos",
                        isSelected: _currentIndex == 1,
                        onTap: () => _onTabTapped(1),
                        activeColor: color5,
                      ),

                      // Center: Gradient Add Button
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [color1, color5],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: color5.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: _onAddPhotoTapped,
                            customBorder: const CircleBorder(),
                            splashColor: Colors.white.withOpacity(0.3),
                            hoverColor: Colors.white.withOpacity(0.1),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      // Tab 3: Admin/Profile (Index updated to 2)
                      _NavBarIcon(
                        icon: _userRole == 'admin'
                            ? Icons.admin_panel_settings_rounded
                            : Icons.person_rounded,
                        label: _userRole == 'admin' ? "Admin" : "Profile",
                        isSelected: _currentIndex == 2,
                        onTap: () => _onTabTapped(2),
                        activeColor: color5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper Widget (Unchanged from previous version)
class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavBarIcon({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        hoverColor: activeColor.withOpacity(0.1),
        splashColor: activeColor.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Slightly reduced padding for space
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: activeColor.withOpacity(0.3),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: isSelected ? activeColor : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}