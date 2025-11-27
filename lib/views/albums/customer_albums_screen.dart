import 'package:flutter/material.dart';
import '../components/album_card.dart'; // Assuming this exists from your previous uploads
import 'customer_request_grid_screen.dart'; // The new screen below

class CustomerAlbumsScreen extends StatelessWidget {
  const CustomerAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data representing customers who sent photos
    final List<Map<String, dynamic>> customerRequests = [
      {
        "name": "chriscyrl",
        "style": "Industrial Minimalist",
        "notes": "Focus on the lighting details.",
        "count": 15,
        "date": "Oct 24, 2023"
      },
      {
        "name": "jane_design",
        "style": "Boho Chic",
        "notes": "Looking for warm tones.",
        "count": 8,
        "date": "Oct 23, 2023"
      },
      {
        "name": "mike_studio",
        "style": "Modern Art",
        "notes": "High contrast needed.",
        "count": 22,
        "date": "Oct 22, 2023"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Customer Photos"),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
              dateCreated: request["date"],
              itemCount: request["count"],
              onTap: () {
                // Navigate to the new Grid Screen with Details Header
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerRequestGridScreen(
                      customerName: request["name"],
                      styleRequest: request["style"],
                      notes: request["notes"],
                    ),
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