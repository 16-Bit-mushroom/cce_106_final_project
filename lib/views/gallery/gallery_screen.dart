import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// MAKE SURE THIS PATH IS CORRECT. If you moved the file, update this line.
import 'package:cce_106_final_project/views/albums/customer_request_grid_screen.dart'; 

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // State for the Dropdowns
  String _selectedStatus = 'All';
  String _selectedStyle = 'All';

  // --- Logic: Time Ago Formatter ---
  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return '';
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 1) {
      return "${date.month}/${date.day}";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inMinutes}m ago";
    } else {
      return "Just now";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> statusOptions = ['All', 'Pending', 'Completed'];
    final List<String> styleOptions = ['All', 'Anime', 'Sketch', 'Cartoon'];

    // SEVENTEEN Color Palette
    const color1 = Color(0xFFf7cac9); 
    const color2 = Color(0xFFdec2cb);
    const color3 = Color(0xFFc5b9cd);
    const color4 = Color(0xFFabb1cf);
    const color5 = Color(0xFF92a8d1); 

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color1, color2, color3, color4, color5],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Header
            SliverToBoxAdapter(
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
                        Icons.layers_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      "Request Queue",
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

            // 2. Dropdown Filters Row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildGlassDropdown(
                        value: _selectedStatus,
                        items: statusOptions,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                        icon: Icons.filter_list,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGlassDropdown(
                        value: _selectedStyle,
                        items: styleOptions,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStyle = val);
                        },
                        icon: Icons.palette_outlined,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // 3. Realtime Request List
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: Supabase.instance.client
                  .from('requests')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                }

                final allRequests = snapshot.data!;

                // Filtering Logic
                final filteredRequests = allRequests.where((req) {
                  final status = (req['status'] ?? 'pending').toString();
                  final style = (req['style_type'] ?? '').toString();

                  final statusMatch =
                      _selectedStatus == 'All' ||
                      status.toLowerCase() == _selectedStatus.toLowerCase();
                  final styleMatch =
                      _selectedStyle == 'All' ||
                      style.toLowerCase() == _selectedStyle.toLowerCase();

                  return statusMatch && styleMatch;
                }).toList();

                if (filteredRequests.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            "No requests match.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final req = filteredRequests[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: _buildRequestRow(context, req),
                    );
                  }, childCount: filteredRequests.length),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    final safeValue = items.contains(value) ? value : items.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          icon: Icon(icon, color: const Color(0xFF92a8d1)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(20),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          isExpanded: true,
          items: items.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRequestRow(BuildContext context, Map<String, dynamic> item) {
    final status = item['status'] ?? 'pending';
    
    // --- FIX: NULL SAFETY FOR IMAGE PATH ---
    final originalPath = item['original_image_path'];
    String imageUrl = '';
    
    if (originalPath != null && originalPath.toString().isNotEmpty) {
      imageUrl = Supabase.instance.client.storage
          .from('photos')
          .getPublicUrl(originalPath);
    }
    // ---------------------------------------

    final timeAgo = _formatTimeAgo(item['created_at']);
    final senderName = item['sender_name'] ?? 'Anonymous';

    final isCompleted = status == 'completed';
    final statusColor = isCompleted ? Colors.teal : const Color(0xFFE5989B);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF92a8d1).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            // FIX: Ensure this file actually exists in this folder structure!
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CustomerRequestGridScreen(request: item),
              ),
            );
          },
          splashColor: Colors.white.withOpacity(0.4),
          highlightColor: Colors.white.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // --- THUMBNAIL IMAGE ---
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageUrl.isNotEmpty 
                        ? Image.network(
                            imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.white,
                              child: const Icon(Icons.broken_image,
                                  size: 20, color: Colors.grey),
                            ),
                          )
                        : Container( // Fallback if URL is empty
                            width: 60,
                            height: 60,
                            color: Colors.white.withOpacity(0.5),
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // --- TEXT CONTENT ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['style_type'] ?? "New Request",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      Text(
                        "From: $senderName",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // --- PROCESS BUTTON ---
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerRequestGridScreen(request: item),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF92a8d1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Process",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}