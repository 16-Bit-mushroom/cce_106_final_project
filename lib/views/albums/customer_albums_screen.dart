import 'package:flutter/material.dart';
import '../components/album_card.dart';
import 'customer_request_grid_screen.dart';

class CustomerAlbumsScreen extends StatelessWidget {
  const CustomerAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UPDATED MOCK DATA: Matches Supabase "requests" table structure
    final List<Map<String, dynamic>> customerRequests = [
      {
        "id": "mock_id_12345",
        "name": "chriscyrl", // Helper field for display
        "style_type": "Industrial Minimalist", // Mapped to style_type
        "notes": "Focus on the lighting details.",
        "status": "pending",
        "original_image_path": "mock/path/image1.jpg", // Prevents null crash
        "count": 15,
        "created_at": "Oct 24, 2023",
      },
      {
        "id": "mock_id_67890",
        "name": "jane_design",
        "style_type": "Boho Chic",
        "notes": "Looking for warm tones.",
        "status": "completed",
        "original_image_path": "mock/path/image2.jpg",
        "count": 8,
        "created_at": "Oct 23, 2023",
      },
      {
        "id": "mock_id_11223",
        "name": "mike_studio",
        "style_type": "Modern Art",
        "notes": "High contrast needed.",
        "status": "pending",
        "original_image_path": "mock/path/image3.jpg",
        "count": 22,
        "created_at": "Oct 22, 2023",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer Photos"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          padding: const EdgeInsets.only(top: 16, bottom: 120),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: customerRequests.length,
          itemBuilder: (context, index) {
            final request = customerRequests[index];

            return AlbumCard(
              index: index,
              albumName: request["name"],
              owner: "Customer",
              dateCreated: request["created_at"],
              itemCount: request["count"],
              onTap: () {
                // FIXED: Now passes the map as 'request'
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CustomerRequestGridScreen(request: request),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
