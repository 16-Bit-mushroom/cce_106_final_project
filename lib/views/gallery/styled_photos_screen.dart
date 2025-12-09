import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/gallery/styled_photo_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart'; // Make sure to add this dependency

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

  // --- SEVENTEEN Palette (From Gallery Screen) ---
  final Color color1 = const Color(0xFFf7cac9); // Rose Quartz
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1); // Serenity

  @override
  void initState() {
    super.initState();
    _photosFuture = _loadData();
  }

  // --- DATA LOADING LOGIC ---
  Future<List<Map<String, dynamic>>> _loadData() async {
    try {
      print("DEBUG: Fetching COMPLETED requests only...");

      final response = await Supabase.instance.client
          .from('requests')
          .select('*')
          .eq('status', 'completed')
          .order('created_at', ascending: false);

      print("DEBUG: Found ${response.length} completed photos.");
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("DEBUG ERROR: $e");
      rethrow;
    }
  }

  // --- SELECTION LOGIC ---
  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      if (_selectedIds.isEmpty) _isSelectionMode = false;
    });
  }

  void _enterSelectionMode(String id) {
    setState(() {
      _isSelectionMode = true;
      _selectedIds.add(id);
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedIds.clear();
    });
  }

  // --- ACTIONS ---
  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete ${_selectedIds.length} Photos?"),
        content: const Text("This action cannot be undone."),
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

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('requests')
            .delete()
            .filter('id', 'in', _selectedIds.toList());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Photos deleted successfully.")),
          );
        }
        _exitSelectionMode();
        setState(() {
          _photosFuture = _loadData();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error deleting: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // --- NEW: Download Logic ---
  Future<void> _downloadSelected() async {
    // Note: On Web, this will typically open the image in a new tab where user can save.
    // On Mobile with url_launcher, it attempts to open the link.
    
    // We need to fetch the data first to get the paths
    final allPhotos = await _photosFuture;
    final selectedPhotos = allPhotos.where((p) => _selectedIds.contains(p['id'].toString())).toList();

    if (selectedPhotos.isEmpty) return;

    int successCount = 0;
    for (var photo in selectedPhotos) {
      final path = photo['styled_image_path'];
      if (path != null) {
        final url = Supabase.instance.client.storage.from('photos').getPublicUrl(path);
        final uri = Uri.parse(url);
        
        try {
          if (await canLaunchUrl(uri)) {
             await launchUrl(uri, mode: LaunchMode.externalApplication);
             successCount++;
          } else {
             print("Could not launch $url");
          }
        } catch (e) {
           print("Error launching url: $e");
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Opened $successCount photos. Save them from your browser."),
          backgroundColor: color5,
        ),
      );
    }
    _exitSelectionMode();
  }

  void _printSelected() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Printing ${_selectedIds.length} photos..."),
        backgroundColor: color5,
      ),
    );
    _exitSelectionMode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _isSelectionMode
          ? AppBar(
              backgroundColor: color5.withOpacity(0.95),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              ),
              title: Text(
                "${_selectedIds.length} Selected",
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
                // --- NEW DOWNLOAD BUTTON ---
                IconButton(
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  onPressed: _downloadSelected,
                  tooltip: "Download/Save",
                ),
                IconButton(
                  icon: const Icon(Icons.print, color: Colors.white),
                  onPressed: _printSelected,
                  tooltip: "Print",
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _deleteSelected,
                  tooltip: "Delete",
                ),
              ],
            )
          : null,

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3, color4, color5],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _photosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Colors.white.withOpacity(0.8),
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Error loading photos:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }

            final photos = snapshot.data ?? [];

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _photosFuture = _loadData();
                });
                await _photosFuture;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // A. Header
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "Gallery",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // B. Empty State or Grid
                  if (photos.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.all(30),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  "No completed photos yet.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.8, // Slightly taller for more text space
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final photoData = photos[index];
                          final path = photoData['styled_image_path'];
                          if (path == null || path.toString().isEmpty) {
                            return _buildStatusPlaceholder(photoData);
                          }
                          return _buildGlassPhotoTile(photoData);
                        }, childCount: photos.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Widget for Items WITHOUT Photos (Pending) ---
  Widget _buildStatusPlaceholder(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Unknown';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.hourglass_empty_rounded,
              color: Colors.white,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              status.toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget for Items WITH Photos ---
  Widget _buildGlassPhotoTile(Map<String, dynamic> data) {
    final id = data['id'].toString();
    final imagePath = data['styled_image_path'];
    // 1. EXTRACT SENDER NAME
    final senderName = data['sender_name'] ?? 'Anonymous';
    final isSelected = _selectedIds.contains(id);

    final imageUrl = Supabase.instance.client.storage
        .from('photos')
        .getPublicUrl(imagePath);

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(id);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StyledPhotoDetailScreen(data: data),
            ),
          );
        }
      },
      onLongPress: () => _enterSelectionMode(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color5 : Colors.white.withOpacity(0.8),
            width: isSelected ? 4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF92a8d1).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                      bottom: Radius.circular(4),
                    ),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: color5,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (ctx, err, stack) {
                        return Container(
                          color: Colors.grey.withOpacity(0.2),
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isSelectionMode)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? color5
                              : Colors.black.withOpacity(0.3),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            // Footer Area
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['style_type'] ?? "Styled",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF4A4A4A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // 2. SHOW SENDER NAME
                  Text(
                    "By $senderName",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  
                  // Status Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "DONE",
                          style: TextStyle(
                            color: Colors.teal,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}