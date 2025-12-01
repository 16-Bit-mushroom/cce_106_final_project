import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/login_screen.dart';
import 'package:cce_106_final_project/views/albums/customer_request_grid_screen.dart'; // <-- NEW IMPORT

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          ),
          child: const Text("Log In"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Header (Dashboard Title & Avatar)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // 2. The Big "Gallery" Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Gallery",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildGalleryButton("All Photos")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildGalleryButton("Customer\nPhotos")),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Requests",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // 3. The Realtime Request List
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from('requests')
                .stream(primaryKey: ['id'])
                // NOTE: Staff should see ALL requests, so we removed the user_id filter
                .order('created_at', ascending: false),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              final requests = snapshot.data!;

              if (requests.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text(
                        "No pending requests.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final req = requests[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    child: _buildRequestRow(context, req), // Pass context here
                  );
                }, childCount: requests.length),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildGalleryButton(String label) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black87, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // UPDATED: Now handles navigation on tap
  Widget _buildRequestRow(BuildContext context, Map<String, dynamic> item) {
    final status = item['status'] ?? 'pending';
    final imageUrl = Supabase.instance.client.storage
        .from('photos')
        .getPublicUrl(item['original_image_path']);

    return GestureDetector(
      // <-- ENTIRE ROW IS TAPABLE
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CustomerRequestGridScreen(request: item), // Pass the whole item
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black87, width: 1.5),
        ),
        child: Row(
          children: [
            // Small Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['style_type'] ?? "New Request",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: status == 'completed'
                          ? Colors.green
                          : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // View Button (Visual)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black87, width: 1.5),
              ),
              child: const Text(
                "view",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
