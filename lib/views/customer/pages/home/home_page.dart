import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// IMPORTS: These connect the Home Page to the other pages we created
import '../requests/requests_page.dart';
import '../albums/albums_page.dart';
import '../../modals/send_photo_modal.dart'; // Ensure this path matches where you put the modal
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Primary color from your theme (or hardcoded orange for now)
    final primaryColor = Colors.orange.shade300;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Navigation Bar
              _buildTopNavBar(context),

              const Spacer(),

              // 2. Center Action Area (The "X" Box from Wireframe)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The Icon Box
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, size: 50),
                    ),
                    const SizedBox(height: 30),

                    // The "Send Photos" Button
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.orange),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () => _handleSendPhotos(context),
                        child: const Text(
                          "Send Photos",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 3. Helper Text at Bottom
              const Center(
                child: Text(
                  "We will style your photos professionally.",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // LOGIC: Pick images -> Open Modal
  Future<void> _handleSendPhotos(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    // 1. Open Gallery
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty && context.mounted) {
      // 2. Open the Send Modal with selected images
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SendPhotoModal(selectedImages: images),
      );
    }
  }

  // WIDGET: Top Navigation Bar
  // WIDGET: Top Navigation Bar
  Widget _buildTopNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Links (Navigation)
        Row(
          children: [
            _navLink(
              context,
              "Requests",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestsPage()),
              ),
            ),
            const SizedBox(width: 20),
            _navLink(
              context,
              "Albums",
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlbumsPage()),
              ),
            ),
            const SizedBox(width: 20),
            _navLink(context, "Photos", () {}), // Placeholder for now
          ],
        ),

        // Right Icons (Notifications/Profile)
        Row(
          children: [
            // 1. Notification Icon (Clickable)
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage()),
                );
              },
            ),
            const SizedBox(width: 5),

            // 2. Profile Avatar (Clickable via InkWell)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              borderRadius: BorderRadius.circular(
                50,
              ), // Makes the ripple effect round
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // HELPER: Navigation Link Style
  Widget _navLink(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
