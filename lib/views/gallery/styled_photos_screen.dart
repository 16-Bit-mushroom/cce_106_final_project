import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Update this import if your folder structure changes
import 'package:cce_106_final_project/views/gallery/styled_photo_detail_screen.dart';

class StyledPhotosScreen extends StatefulWidget {
  const StyledPhotosScreen({super.key});

  @override
  State<StyledPhotosScreen> createState() => _StyledPhotosScreenState();
}

class _StyledPhotosScreenState extends State<StyledPhotosScreen> {
  // Selection State
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  // Data State
  late Future<List<Map<String, dynamic>>> _photosFuture;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9);
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1);

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadData();
  }

  // --- 1. SUPABASE FETCH LOGIC (Kept the working version) ---
  Future<List<Map<String, dynamic>>> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await Supabase.instance.client
          .from('requests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'completed') // Only finished images
          .neq('styled_image_path', null)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching photos: $e');
      return [];
    }
  }

  // --- 2. URL GENERATOR (Kept the working version) ---
  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return Supabase.instance.client.storage
        .from('style_transfer_assets')
        .getPublicUrl(path);
  }

  // --- Selection Logic ---
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      _selectedIds.clear();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black87, // Maintained your original dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("My Gallery", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.close : Icons.select_all,
              color: Colors.white,
            ),
            onPressed: _toggleSelectionMode,
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _photosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading gallery',
                style: TextStyle(color: color1),
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(
              child: Text(
                "No styled photos yet.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(10), // Original padding
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10, // Matching your original spacing
              mainAxisSpacing: 10,
              childAspectRatio: 0.75, // Matching your original aspect ratio
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              final id = item['id'] as String;
              final imagePath = item['styled_image_path'] as String?;
              final imageUrl = _getImageUrl(imagePath);
              final isSelected = _selectedIds.contains(id);

              return GestureDetector(
                onTap: () {
                  if (_isSelectionMode) {
                    _toggleSelection(id);
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StyledPhotoDetailScreen(
                          imageUrl: imageUrl,
                          heroTag: id,
                          metadata: item,
                        ),
                      ),
                    );
                  }
                },
                onLongPress: () {
                  if (!_isSelectionMode) {
                    _toggleSelectionMode();
                    _toggleSelection(id);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // --- Main Image Card ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        14,
                      ), // Your specific radius
                      child: Hero(
                        tag: id,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.white10,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  color: color3, // Using your palette
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[900],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    color: Colors.white54,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Error",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // --- Selection Overlay ---
                    if (_isSelectionMode)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: isSelected
                              ? color5.withOpacity(0.4) // Your specific opacity
                              : Colors.black.withOpacity(0.1),
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
