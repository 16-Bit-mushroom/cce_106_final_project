import 'package:flutter/material.dart';
import 'package:cce_106_final_project/views/gallery/gallery_screen.dart';
import 'package:cce_106_final_project/views/selection/image_selection.dart';
import 'package:cce_106_final_project/views/admin/admin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;
  String _userRole = 'user'; // Default role
  bool _loadingRole = true;
  static const double kMaxWidth = 800.0;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // --- Fetch the user's role from Supabase 'profiles' table ---
  Future<void> _fetchUserRole() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userRole = data['role'] ?? 'user';
          _loadingRole = false;
        });
      }
    } catch (e) {
      print("Error fetching role: $e");
      // Fallback to 'user' if fetch fails, but stop loading
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
    // 1. Show loading spinner while checking admin status
    if (_loadingRole) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Define our screens
    final List<Widget> screens = [
      const GalleryScreen(),
      // Pass the fetched role to AdminScreen so it knows what to show
      AdminScreen(currentUserRole: _userRole),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.grey[100],

      // Main Body Content
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
                ),
              ],
            ),
            // IndexedStack keeps the state of screens alive when switching tabs
            child: IndexedStack(index: _currentIndex, children: screens),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kMaxWidth),
          child: SafeArea(
            child: Container(
              height: 70,
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
                  // Tab 1: Dashboard / Requests
                  _NavBarIcon(
                    icon: Icons.dashboard_outlined,
                    label: "Requests",
                    isSelected: _currentIndex == 0,
                    onTap: () => _onTabTapped(0),
                  ),

                  // Center Button: Add New Request
                  GestureDetector(
                    onTap: _onAddPhotoTapped,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8B553), // App Accent Color
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

                  // Tab 2: Admin / Profile
                  _NavBarIcon(
                    // Change icon based on role for clear visual feedback
                    icon: _userRole == 'admin'
                        ? Icons.admin_panel_settings_outlined
                        : Icons.person_outline,
                    label: _userRole == 'admin' ? "Admin" : "Profile",
                    isSelected: _currentIndex == 1,
                    onTap: () => _onTabTapped(1),
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

// Helper Widget for Nav Icons
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
