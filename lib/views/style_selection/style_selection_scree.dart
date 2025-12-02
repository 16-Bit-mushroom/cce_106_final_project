// import 'package:cce_106_final_project/services/gemini_service.dart';
import 'package:cce_106_final_project/views/components/style_option_card.dart';
import 'package:cce_106_final_project/views/style_selection/style_result_screen.dart';
import 'package:flutter/material.dart';
import 'dart:io' show File; // Only import File from dart:io
import 'dart:typed_data'; // For Uint8List
import 'package:cce_106_final_project/services/stability_service.dart';

class StyleSelectionScreen extends StatefulWidget {
  // It's better to accept bytes or a path/url
  // We'll make it flexible:
  final String? imagePath; // For native mobile (File path) or network URL
  final Uint8List? imageBytes; // For web (image bytes from image_picker)

  // NEW: Accept request data to track ID
  final Map<String, dynamic>? requestData;

  const StyleSelectionScreen({
    super.key,
    this.imagePath,
    this.imageBytes,
    this.requestData,
  });

  @override
  State<StyleSelectionScreen> createState() => _StyleSelectionScreenState();
}

class _StyleSelectionScreenState extends State<StyleSelectionScreen> {
  String? _selectedStyle;

  bool _isProcessing = false;

  final List<String> _availableStyles = const [
    "Anime",
    "Cyberpunk",
    "Cartoon",
    "Sketch",
    "3D Model",
  ];

  // Enhanced version with better web handling
  Widget _buildImagePreview() {
    try {
      if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
        // For web, use Image.memory
        return Image.memory(
          widget.imageBytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Error loading image from bytes: $error");
            return _buildErrorPlaceholder();
          },
        );
      } else if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        // For native, use Image.file
        return Image.file(
          File(widget.imagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint("Error loading image from file path: $error");
            return _buildErrorPlaceholder();
          },
        );
      } else {
        // No image selected
        return _buildErrorPlaceholder();
      }
    } catch (e) {
      debugPrint("Unexpected error in image preview: $e");
      return _buildErrorPlaceholder();
    }
  }

  Widget _buildErrorPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 50,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            "Select an image to preview",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _applyStyle() async {
    // Check for nulls first
    if (_selectedStyle == null) {
      _showError('Please select a style first.');
      return;
    }
    if (widget.imageBytes == null) {
      _showError('No image is available to style.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      print('🎨 Starting style application for: $_selectedStyle');
      print('📸 Image bytes available: ${widget.imageBytes!.length} bytes');

      // Call the correct function (generateStyledImage) and pass it
      // the user's selected image and style.
      Uint8List? styledImageBytes = await StabilityService.generateStyledImage(
        imageBytes: widget.imageBytes!,
        style: _selectedStyle!,
      );

      if (styledImageBytes != null) {
        print('✅ Styled image generated successfully');
        // Pass the original image bytes AND the new styled bytes
        _navigateToResultScreen(widget.imageBytes!, styledImageBytes);
      } else {
        // If the API call fails (returns null)
        _showError('Failed to apply style. Check console for API errors.');
      }
    } catch (e) {
      print('💥 Error in _applyStyle: $e');
      _showError('An unexpected error occurred: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // Updated this function to accept both original and styled bytes
  void _navigateToResultScreen(
    Uint8List originalImageBytes,
    Uint8List styledImageBytes,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleResultScreen(
          originalImageBytes: originalImageBytes, // Pass the original
          styledImageBytes: styledImageBytes, // Pass the new one
          styleName: _selectedStyle!,
          // NEW: Pass the request data forward
          requestData: widget.requestData,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose a Style")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildImagePreview(), // Use the flexible builder
              ),
            ),

            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: _availableStyles.length,
                itemBuilder: (context, index) {
                  final style = _availableStyles[index];
                  return StyleOptionCard(
                    styleName: style,
                    isSelected: _selectedStyle == style,
                    onTap: () {
                      setState(() {
                        _selectedStyle = style;
                      });
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedStyle == null || _isProcessing)
                    ? null
                    : _applyStyle,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.5),
                  disabledForegroundColor: Colors.white70,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Applying Style..."),
                        ],
                      )
                    : const Text(
                        "Apply Style",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
