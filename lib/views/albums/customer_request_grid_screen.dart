import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/style_selection/style_selection_scree.dart';
import 'dart:typed_data'; // <--- ADDED THIS IMPORT

class CustomerRequestGridScreen extends StatefulWidget {
  final Map<String, dynamic> request; // We now accept the full request map

  const CustomerRequestGridScreen({super.key, required this.request});

  @override
  State<CustomerRequestGridScreen> createState() =>
      _CustomerRequestGridScreenState();
}

class _CustomerRequestGridScreenState extends State<CustomerRequestGridScreen> {
  bool _isDownloading = false;

  // --- Image Fetch Logic ---
  // When Staff clicks "Process AI", we need the image bytes first.
  Future<Uint8List?> _fetchImageBytes() async {
    setState(() => _isDownloading = true);
    try {
      final path = widget.request['original_image_path'];
      if (path == null) throw Exception("Image path is missing.");

      final bytes = await Supabase.instance.client.storage
          .from('photos')
          .download(path);

      return bytes;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error fetching image: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _processAiStyle() async {
    final imageBytes = await _fetchImageBytes();

    if (imageBytes != null && mounted) {
      // Navigate to the AI Style Generation Screen, passing the bytes
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StyleSelectionScreen(
            imageBytes: imageBytes,
            // Pass the request ID so we can update the DB after generation
            requestData: widget.request,
          ),
        ),
      );
    }
  }

  // --- Selection Logic ---
  final Set<int> _selectedIndices = {};
  final int _totalItems = 1;

  void _cancelSelection() {
    setState(() {
      _selectedIndices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final styleRequest = widget.request['style_type'] ?? 'Style Not Specified';
    final requestStatus = widget.request['status'] ?? 'pending';
    final originalImagePath = widget.request['original_image_path'];
    // Handle cases where ID might be null or not a string safely
    final requestId = widget.request['id']?.toString() ?? 'Unknown ID';
    final shortId = requestId.length > 8
        ? requestId.substring(0, 8)
        : requestId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(shortId),
        actions: [
          // If the request hasn't been processed, show the AI button
          if (requestStatus == 'pending')
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : _processAiStyle,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isDownloading ? "Loading..." : "Process AI"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. THE DETAILS CARD (Header)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Request ID: $shortId",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Style Requested:", styleRequest),
                    const SizedBox(height: 8),
                    _buildDetailRow("Status:", requestStatus.toUpperCase()),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),

          // 2. THE PHOTO DISPLAY (Original Image)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Original Source Photo",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1.5, // Standard photo aspect
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: originalImagePath != null
                          ? Image.network(
                              Supabase.instance.client.storage
                                  .from('photos')
                                  .getPublicUrl(originalImagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Text("No Image Path Found"),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black87, fontSize: 14),
        children: [
          TextSpan(
            text: "$label ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
