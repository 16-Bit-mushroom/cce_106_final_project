import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to add this dependency

class StyledPhotoDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const StyledPhotoDetailScreen({super.key, required this.data});

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9);
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1);

  // Helper to format date
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[date.month - 1]}. ${date.day}, ${date.year}";
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _deletePhoto(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Photo?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await Supabase.instance.client
            .from('requests')
            .delete()
            .eq('id', data['id']);
        if (context.mounted) {
          Navigator.pop(context); // Return to grid
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Photo deleted.")));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // --- NEW: Download Logic ---
  Future<void> _downloadPhoto(BuildContext context) async {
     final styledImagePath = data['styled_image_path'];
     if (styledImagePath != null) {
       final url = Supabase.instance.client.storage.from('photos').getPublicUrl(styledImagePath);
       final uri = Uri.parse(url);
       try {
         if (await canLaunchUrl(uri)) {
           await launchUrl(uri, mode: LaunchMode.externalApplication);
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Opening image in browser...")),
             );
           }
         } else {
           if (context.mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("Could not launch image URL.")),
             );
           }
         }
       } catch (e) {
          debugPrint("Error launching URL: $e");
       }
     }
  }

  @override
  Widget build(BuildContext context) {
    final styledImagePath = data['styled_image_path'];
    final imageUrl = Supabase.instance.client.storage
        .from('photos')
        .getPublicUrl(styledImagePath);
    final style = data['style_type'] ?? 'Unknown';
    final dateStr = _formatDate(data['created_at']);
    final senderName = data['sender_name'] ?? 'Anonymous';
    final notes = data['notes'] ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color1, color2, color3, color4, color5],
              ),
            ),
          ),

          // 2. Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- GLASS CARD ---
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white),
                            boxShadow: [
                              BoxShadow(
                                color: color5.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HEADER ROW (Name & Style)
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          senderName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          dateStr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color5.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: color5.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      style,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // --- IMAGE DISPLAY (UPDATED) ---
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                    color: Colors
                                        .black, // Dark background looks better for photos
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: InteractiveViewer(
                                      minScale: 0.5,
                                      maxScale: 4.0,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit
                                            .contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.white54,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // NOTES CAPTION
                              if (notes.toString().isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.05),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.edit_note_rounded,
                                            size: 16,
                                            color: color5,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Journal Entry",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notes,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black87,
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- ACTIONS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Center icons
                    children: [
                      // --- NEW: Download Icon ---
                      _buildActionIcon(
                        icon: Icons.download_rounded,
                        color: Colors.black87,
                        onTap: () => _downloadPhoto(context),
                      ),
                      const SizedBox(width: 16),
                      // Print Icon
                      _buildActionIcon(
                        icon: Icons.print_rounded,
                        color: Colors.black87,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Printing...")),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      // Delete Icon
                      _buildActionIcon(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.black87,
                        onTap: () => _deletePhoto(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}