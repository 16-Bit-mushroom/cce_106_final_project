import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:cce_106_final_project/services/stability_service.dart';
import 'package:cce_106_final_project/views/style_selection/style_result_screen.dart';

class StyleSelectionScreen extends StatefulWidget {
  final String? imagePath;
  final Uint8List? imageBytes;
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

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9); // Rose Quartz
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1); // Serenity

  // --- LOGIC: IMAGE PREVIEW (Untouched logic, updated UI) ---
  Widget _buildImagePreview() {
    try {
      Widget imageWidget;
      if (widget.imageBytes != null && widget.imageBytes!.isNotEmpty) {
        imageWidget = Image.memory(widget.imageBytes!, fit: BoxFit.cover);
      } else if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        imageWidget = Image.file(File(widget.imagePath!), fit: BoxFit.cover);
      } else {
        return _buildErrorPlaceholder();
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: imageWidget,
      );
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
          Icon(Icons.image_not_supported_outlined,
              size: 40, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(
            "No Image",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: APPLY STYLE (Untouched) ---
  void _applyStyle() async {
    if (_selectedStyle == null) {
      _showError('Please select a style first.');
      return;
    }
    if (widget.imageBytes == null) {
      _showError('No image is available to style.');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      Uint8List? styledImageBytes = await StabilityService.generateStyledImage(
        imageBytes: widget.imageBytes!,
        style: _selectedStyle!,
      );

      if (styledImageBytes != null) {
        _navigateToResultScreen(widget.imageBytes!, styledImageBytes);
      } else {
        _showError('Failed to apply style. Check console for API errors.');
      }
    } catch (e) {
      _showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _navigateToResultScreen(
    Uint8List originalImageBytes,
    Uint8List styledImageBytes,
  ) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StyleResultScreen(
          originalImageBytes: originalImageBytes,
          styledImageBytes: styledImageBytes,
          styleName: _selectedStyle!,
          requestData: widget.requestData,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Choose Style",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black12, blurRadius: 4)],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
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

          // 2. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  // --- PREVIEW CARD ---
                  Expanded(
                    flex: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                color: color5.withOpacity(0.15),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text(
                                "Preview",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: _buildImagePreview(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- STYLE GRID ---
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8, bottom: 12),
                          child: Text(
                            "Select Art Style",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(color: Colors.black12, blurRadius: 4)
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.85,
                            ),
                            itemCount: _availableStyles.length,
                            itemBuilder: (context, index) {
                              final style = _availableStyles[index];
                              return _buildGlassStyleCard(style);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- APPLY BUTTON ---
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: _isProcessing
                          ? null
                          : LinearGradient(
                              colors: [color5, const Color(0xFF7B92CC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: _isProcessing ? Colors.white.withOpacity(0.5) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isProcessing
                          ? []
                          : [
                              BoxShadow(
                                color: color5.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: (_selectedStyle == null || _isProcessing)
                          ? null
                          : _applyStyle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Generating...",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ],
                            )
                          : const Text(
                              "Generate Art",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER: CUSTOM GLASS STYLE CARD ---
  Widget _buildGlassStyleCard(String style) {
    final isSelected = _selectedStyle == style;

    return GestureDetector(
      onTap: () => setState(() => _selectedStyle = style),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color5 : Colors.white.withOpacity(0.4),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color5.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon based on style name (Optional polish)
            Icon(
              _getIconForStyle(style),
              color: isSelected ? color5 : Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              style,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? color5 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStyle(String style) {
    switch (style) {
      case "Anime":
        return Icons.auto_awesome;
      case "Cyberpunk":
        return Icons.memory;
      case "Cartoon":
        return Icons.emoji_emotions_outlined;
      case "Sketch":
        return Icons.create_outlined;
      case "3D Model":
        return Icons.view_in_ar;
      default:
        return Icons.brush_outlined;
    }
  }
}