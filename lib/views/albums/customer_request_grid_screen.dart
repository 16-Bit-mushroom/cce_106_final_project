import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import '../components/photo_view_screen.dart'; // Ensure this is imported

class CustomerRequestGridScreen extends StatefulWidget {
  final String customerName;
  final String styleRequest;
  final String notes;

  const CustomerRequestGridScreen({
    super.key,
    required this.customerName,
    required this.styleRequest,
    required this.notes,
  });

  @override
  State<CustomerRequestGridScreen> createState() => _CustomerRequestGridScreenState();
}

class _CustomerRequestGridScreenState extends State<CustomerRequestGridScreen> {
  // --- Selection Logic Copied from PhotoGridScreen ---
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  final int _totalItems = 15; // Example count

  void _toggleItemSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
        if (_selectedIndices.isEmpty) _isSelectionMode = false;
      } else {
        _selectedIndices.add(index);
        _isSelectionMode = true;
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _selectedIndices.clear();
      _isSelectionMode = false;
    });
  }
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          _isSelectionMode 
            ? "${_selectedIndices.length} Selected" 
            : "${widget.customerName}'s Photos",
          style: const TextStyle(color: Colors.black),
        ),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.print),
                  onPressed: () {
                    // Print logic here
                  },
                ),
                TextButton(
                  onPressed: _cancelSelection,
                  child: const Text("Done"),
                ),
              ]
            : null,
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
                  boxShadow: const [
                     BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                     )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.customerName,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const Chip(label: Text("Pending Review"))
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow("Style Request:", widget.styleRequest),
                    const SizedBox(height: 8),
                    _buildDetailRow("Notes:", widget.notes),
                  ],
                ),
              ),
            ),
          ),

          // 2. THE PHOTO GRID
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childCount: _totalItems,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndices.contains(index);
                
                // Logic to generate random aspect ratios for demo
                final double aspectRatio = (index % 3 == 0) ? 1.0 : (index % 2 == 0 ? 0.7 : 1.3);
                
                return GestureDetector(
                  onLongPress: () => _toggleItemSelection(index),
                  onTap: () {
                    if (_isSelectionMode) {
                      _toggleItemSelection(index);
                    } else {
                      // Navigate to viewer
                    }
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          color: Colors.grey[200],
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Image.network(
                              'https://picsum.photos/seed/${index + 100}/400/600',
                              fit: BoxFit.cover,
                              errorBuilder: (c,o,s) => const Icon(Icons.image),
                            ),
                          ),
                        ),
                      ),
                      if (_isSelectionMode)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black.withOpacity(0.4) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                            ),
                            child: isSelected 
                              ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 32))
                              : null,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Extra padding at bottom so items aren't hidden by nav bars
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
          TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}