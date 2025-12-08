import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${months[date.month - 1]}. ${date.day}, ${date.year}";
    } catch(e) {
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
             onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.white))),
        ],
      ),
    );

    if(confirmed == true && context.mounted) {
       try {
        await Supabase.instance.client.from('requests').delete().eq('id', data['id']);
        if(context.mounted) {
           Navigator.pop(context); // Return to grid
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo deleted.")));
        }
       } catch(e) {
         if(context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
         }
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    final styledImagePath = data['styled_image_path'];
    final imageUrl = Supabase.instance.client.storage.from('photos').getPublicUrl(styledImagePath);
    final style = data['style_type'] ?? 'Unknown';
    final dateStr = _formatDate(data['created_at']);

    // Extract Sender Name
    String senderName = "Unknown Sender";
    if (data['profiles'] != null && data['profiles']['email'] != null) {
       senderName = data['profiles']['email'].split('@')[0];
       // Capitalize first letter (e.g. "wruce" -> "Wruce")
       if (senderName.isNotEmpty) {
         senderName = senderName[0].toUpperCase() + senderName.substring(1);
       }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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

          // 2. Main Wireframe Layout
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- THE MAIN CARD ---
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85), // Higher opacity for paper-like feel from sketch
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
                              // TOP ROW: Name + Date (Left) --- Style (Right)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        senderName, 
                                        style: const TextStyle(
                                          fontSize: 20, 
                                          fontWeight: FontWeight.bold, 
                                          color: Colors.black87
                                        )
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        dateStr, 
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ],
                                  ),
                                  // Style Label
                                  Text(
                                    style, 
                                    style: const TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87
                                    )
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              // MIDDLE: Image Display
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                    color: Colors.grey[100],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- BOTTOM ICONS (Left Aligned as per Sketch) ---
                  Row(
                    children: [
                      // Print Icon
                      _buildActionIcon(
                        icon: Icons.print_rounded,
                        color: Colors.black87,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Printing...")));
                        }
                      ),
                      const SizedBox(width: 16),
                      // Delete Icon
                      _buildActionIcon(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.black87,
                        onTap: () => _deletePhoto(context)
                      ),
                    ],
                  ),
                   const SizedBox(height: 20),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // Helper for the square wireframe buttons
  Widget _buildActionIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50, width: 50,
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