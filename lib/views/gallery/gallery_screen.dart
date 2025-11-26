import 'package:cce_106_final_project/views/albums/customer_albums_screen.dart';
import 'package:flutter/material.dart';
import '../components/gallery_header.dart';
// import '../components/style_grid.dart'; // No longer needed for this specific layout
import 'photo_grid_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // Mock data to simulate the "Customer Requests" list
  final List<Map<String, String>> _requests = [
    {'user': 'chriscyrl', 'date': '2023-10-24', 'status': 'Pending'},
    {'user': 'jane_design', 'date': '2023-10-23', 'status': 'Pending'},
    {'user': 'mike_studio', 'date': '2023-10-22', 'status': 'Reviewed'},
  ];

void _navigateToAlbum(String title) {
    if (title == "Customer Sent Photos") {
      // Navigate to the specific Customer Albums List
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerAlbumsScreen(),
        ),
      );
    } else {
      // Navigate to the generic Photo Grid (All Photos)
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoGridScreen(
            albumTitle: title,
          ),
        ),
      );
    }
  }

  // The Modal described in the wireframe
  void _showRequestDetails(Map<String, String> request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to expand
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Request from ${request['user']}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text("Details:", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text("• 15 Photos sent"),
              const Text("• Style requested: Minimalist/Industrial"),
              const Text("• Notes: Please focus on the lighting details."),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Close"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToAlbum("${request['user']}'s Photos");
                      },
                      child: const Text("View Photos"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // 1. Header
              const GalleryHeader(),
              const SizedBox(height: 24),

              // 2. Top Section: Two Main Album Cards
              Row(
                children: [
                  Expanded(
                    child: _buildAlbumCard(
                      title: "All\nPhotos",
                      onTap: () => _navigateToAlbum("All Styled Photos"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAlbumCard(
                      title: "Customer\nPhotos",
                      onTap: () => _navigateToAlbum("Customer Sent Photos"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // 3. Middle Header
              const Text(
                "Customer Requests",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // 4. Scrollable List of Requests
              Expanded(
                child: ListView.separated(
                  // Padding at bottom to avoid Navbar overlay
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _requests.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildRequestItem(_requests[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for the top two square cards
  Widget _buildAlbumCard({required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Makes them square-ish
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for the list items
  Widget _buildRequestItem(Map<String, String> request) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request['user']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                request['date']!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () => _showRequestDetails(request),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "view",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}