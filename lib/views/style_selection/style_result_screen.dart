import 'package:flutter/material.dart';
import 'dart:typed_data';

class StyleResultScreen extends StatelessWidget {
  final Uint8List? originalImageBytes;
  final Uint8List? styledImageBytes;
  final String styleName;

  const StyleResultScreen({
    super.key,
    this.originalImageBytes,
    this.styledImageBytes,
    required this.styleName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$styleName Style Result"),
        actions: [
          if (styledImageBytes != null)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadImage(context),
              tooltip: 'Download Styled Image',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Before/After Comparison
            Expanded(
              child: Row(
                children: [
                  // Original Image
                  Expanded(
                    child: _buildImageCard(
                      imageBytes: originalImageBytes,
                      title: 'Original',
                      borderColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Styled Image
                  Expanded(
                    child: _buildImageCard(
                      imageBytes: styledImageBytes,
                      title: 'Styled ($styleName)',
                      borderColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Another Style'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: styledImageBytes != null 
                        ? () => _downloadImage(context)
                        : null,
                    child: const Text('Download Styled'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard({
    required Uint8List? imageBytes,
    required String title,
    required Color borderColor,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: borderColor,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            Text('No Image', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadImage(BuildContext context) {
    if (styledImageBytes != null) {
      // TODO: Implement actual download functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Downloading $styleName styled image...'),
          backgroundColor: Colors.green,
        ),
      );
      print('📥 Downloading image of ${styledImageBytes!.length} bytes');
    }
  }
}