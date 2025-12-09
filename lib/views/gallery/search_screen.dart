import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/gallery/styled_photo_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9);
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1);

  final Color textDark = const Color(0xFF4a5e82); 

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      // FIX: Updated Query to search 'notes' OR 'sender_name'
      final response = await Supabase.instance.client
          .from('requests')
          .select('*')
          .eq('status', 'completed')
          .or('notes.ilike.%$query%,sender_name.ilike.%$query%') // <--- NEW LOGIC
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Search Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2, color3, color4, color5],
        ),
      ),
      child: SafeArea(
        bottom: false, 
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: textDark))
                  : _buildResultsGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: textDark, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Search notes or sender...", // Updated Hint
            hintStyle: TextStyle(color: textDark.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            prefixIcon: Icon(Icons.search, color: textDark),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: textDark),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch("");
                    },
                  )
                : null,
          ),
          onSubmitted: _performSearch,
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }

  Widget _buildResultsGrid() {
    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.manage_search, size: 80, color: Colors.white.withOpacity(0.6)),
            const SizedBox(height: 10),
            Text(
              "Type above to search gallery",
              style: TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white.withOpacity(0.2),
          child: Text(
            "No photos found for '${_searchController.text}'",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), 
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return _buildResultTile(_searchResults[index]);
      },
    );
  }

  Widget _buildResultTile(Map<String, dynamic> data) {
    final imagePath = data['styled_image_path'];
    final senderName = data['sender_name'] ?? 'Anonymous'; // Get Sender Name
    
    final imageUrl = Supabase.instance.client.storage
        .from('photos')
        .getPublicUrl(imagePath);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyledPhotoDetailScreen(data: data),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                headers: const {"Access-Control-Allow-Origin": "*"},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.grey));
                },
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image)),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Show Note if available
                      if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                        Text(
                          data['notes'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      // Show Sender Name
                      Text(
                        "By $senderName",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
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