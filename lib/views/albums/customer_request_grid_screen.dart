import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/style_selection/style_selection_scree.dart';
import 'dart:typed_data';

class CustomerRequestGridScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const CustomerRequestGridScreen({super.key, required this.request});

  @override
  State<CustomerRequestGridScreen> createState() =>
      _CustomerRequestGridScreenState();
}

class _CustomerRequestGridScreenState extends State<CustomerRequestGridScreen> {
  bool _isDownloading = false;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9); // Rose Quartz
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1); // Serenity

  // --- Logic: Fetch Image ---
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StyleSelectionScreen(
            imageBytes: imageBytes,
            requestData: widget.request,
          ),
        ),
      );
    }
  }

  // --- Helper: Format Date ---
  String _formatFullDate(String? dateString) {
    if (dateString == null) return "Unknown Date";
    final date = DateTime.parse(dateString).toLocal();
    // Simple formatting: Month/Day/Year Hour:Minute
    return "${date.month}/${date.day}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // Extract Data
    final styleRequest = widget.request['style_type'] ?? 'Style Not Specified';
    final requestStatus = widget.request['status'] ?? 'pending';
    final originalImagePath = widget.request['original_image_path'];
    final requestNotes = widget.request['notes'] ?? 'No journal entry provided.';
    final createdAt = widget.request['created_at']; // New field

    final requestId = widget.request['id']?.toString() ?? 'Unknown ID';
    final shortId = requestId.length > 8 ? requestId.substring(0, 8) : requestId;
    final isPending = requestStatus == 'pending';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Request Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3, color4, color5],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 40),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. GLASS INFO CARD
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ticket #$shortId",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  styleRequest,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            // Status Pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? const Color(0xFFE5989B).withOpacity(0.2)
                                    : Colors.teal.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isPending
                                      ? const Color(0xFFE5989B)
                                      : Colors.teal,
                                ),
                              ),
                              child: Text(
                                requestStatus.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: isPending
                                      ? const Color(0xFFB56576)
                                      : Colors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 30, color: Colors.black12),
                        
                        // Time Details
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 16, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              _formatFullDate(createdAt),
                              style: const TextStyle(
                                  color: Colors.black54, fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Text(
                          "Journal Entry",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            requestNotes,
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. IMAGE SECTION
              const Text(
                "Source Photo",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: color5.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: originalImagePath != null
                      ? Image.network(
                          Supabase.instance.client.storage
                              .from('photos')
                              .getPublicUrl(originalImagePath),
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 200,
                              color: Colors.white.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                    color: Colors.white),
                              ),
                            );
                          },
                          errorBuilder: (c, e, s) => Container(
                            height: 200,
                            color: Colors.white.withOpacity(0.5),
                            child: const Center(
                              child:
                                  Icon(Icons.broken_image, color: Colors.white),
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.white.withOpacity(0.5),
                          child: const Center(child: Text("No Image")),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              // 3. ACTION BUTTON (Only if Pending)
              if (isPending)
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isDownloading ? null : _processAiStyle,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color5,
                      elevation: 5,
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: _isDownloading
                        ? const CircularProgressIndicator(color: Color(0xFF92a8d1))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.auto_awesome),
                              SizedBox(width: 10),
                              Text(
                                "Process with AI",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}