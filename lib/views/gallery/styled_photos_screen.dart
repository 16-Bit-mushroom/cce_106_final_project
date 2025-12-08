import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  // FIX: This variable is now assigned immediately in initState
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
    // FIX: Assign the future immediately so it is not null during build
    _photosFuture = _loadData();
  }

  // --- DEBUG DATA LOADING (FETCHES EVERYTHING) ---
  // FIX: Changed return type to Future<List...> and removed internal setStates
  Future<List<Map<String, dynamic>>> _loadData() async {
    try {
      print("DEBUG: Fetching COMPLETED requests only...");

      // 1. FILTER: Add .eq('status', 'completed')
      final response = await Supabase.instance.client
          .from('requests')
          .select('*')
          .eq('status', 'completed') // <--- ONLY SHOW COMPLETED
          .order('created_at', ascending: false);

      print("DEBUG: Found ${response.length} completed photos.");

      // 2. URL DEBUGGING: Print the URL of the first photo found
      if (response.isNotEmpty) {
        final firstItem = response.first;
        final path = firstItem['styled_image_path'];

        final testUrl = Supabase.instance.client.storage
            .from('photos')
            .getPublicUrl(path);

        print(
          "----------------------------------------------------------------",
        );
        print("DEBUG: Testing First Image URL:");
        print(testUrl);
        print(
          "----------------------------------------------------------------",
        );
      }

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

        // FIX: Reload data by updating the Future
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
              backgroundColor: color5.withOpacity(0.9),
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _exitSelectionMode,
              ),
              title: Text(
                "${_selectedIds.length} Selected",
                style: const TextStyle(color: Colors.white),
              ),
              actions: [
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
          : AppBar(
              title: const Text(
                "All Requests (Debug)",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
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

          // 2. Grid Content
          SafeArea(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        "Error loading photos:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }

                final photos = snapshot.data ?? [];

                if (photos.isEmpty) {
                  return Center(
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
                            "Database is completely empty.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  // FIX: Wrap in setState so the FutureBuilder rebuilds with the new Future
                  onRefresh: () async {
                    setState(() {
                      _photosFuture = _loadData();
                    });
                    await _photosFuture;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: photos.length,
                    itemBuilder: (context, index) {
                      final photoData = photos[index];
                      // Check if image exists, otherwise show status card
                      final path = photoData['styled_image_path'];
                      if (path == null || path.toString().isEmpty) {
                        return _buildStatusPlaceholder(photoData);
                      }
                      return _buildGlassPhotoTile(photoData);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget for Items WITHOUT Photos (Pending) ---
  Widget _buildStatusPlaceholder(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Unknown';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              status.toString().toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color5 : Colors.white.withOpacity(0.5),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                // 1. ADD THIS: Shows a spinner while the image downloads
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                // 2. UPDATED ERROR BUILDER: Prints the actual error to Debug Console
                errorBuilder: (ctx, err, stack) {
                  print("------------------------------------------------");
                  print("IMAGE ERROR for ID $id:");
                  print(err); // <--- This will tell us why it failed
                  print("------------------------------------------------");
                  return Container(
                    color: Colors.white.withOpacity(0.3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, color: Colors.white54),
                        const SizedBox(height: 4),
                        // Show a tiny text so we know it failed
                        const Text(
                          "Error",
                          style: TextStyle(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isSelectionMode)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isSelected
                      ? color5.withOpacity(0.4)
                      : Colors.black.withOpacity(0.1),
                ),
                alignment: Alignment.topRight,
                padding: const EdgeInsets.all(6),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      )
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
