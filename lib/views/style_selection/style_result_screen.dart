import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StyleResultScreen extends StatefulWidget {
  final Uint8List? originalImageBytes;
  final Uint8List? styledImageBytes;
  final String styleName;
  final Map<String, dynamic>? requestData;

  const StyleResultScreen({
    super.key,
    this.originalImageBytes,
    this.styledImageBytes,
    required this.styleName,
    this.requestData,
  });

  @override
  State<StyleResultScreen> createState() => _StyleResultScreenState();
}

class _StyleResultScreenState extends State<StyleResultScreen> {
  bool _isSaving = false;

  // --- SEVENTEEN Palette ---
  final Color color1 = const Color(0xFFf7cac9); // Rose Quartz
  final Color color2 = const Color(0xFFdec2cb);
  final Color color3 = const Color(0xFFc5b9cd);
  final Color color4 = const Color(0xFFabb1cf);
  final Color color5 = const Color(0xFF92a8d1); // Serenity

  // --- LOGIC: SAVE ---
  Future<void> _saveAndComplete() async {
    if (widget.requestData == null || widget.styledImageBytes == null) return;

    setState(() => _isSaving = true);

    try {
      final requestId = widget.requestData!['id'];
      final fileName =
          'styled_${requestId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = 'styled/$fileName';

      await Supabase.instance.client.storage
          .from('photos')
          .uploadBinary(
            filePath,
            widget.styledImageBytes!,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      await Supabase.instance.client
          .from('requests')
          .update({
            'styled_image_path': filePath,
            'status': 'completed',
            'style_type': widget.styleName,
          })
          .eq('id', requestId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved to Album! Request Completed.')),
        );
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalText =
        widget.requestData?['notes'] ?? "No journal entry provided.";
    final dateStr = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Album Preview",
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

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  // Center the list vertically
                  child: Center(
                    child: ListView(
                      shrinkWrap: true, // Hugs content vertically
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // GLASS CARD RESULT
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: color5.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                // UPDATED: Center content horizontally inside the card
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Result Image Container
                                  Container(
                                    // UPDATED: Ensure it spans full width or centers
                                    width: double.infinity, 
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: widget.styledImageBytes != null
                                          ? Image.memory(
                                              widget.styledImageBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(
                                              height: 300,
                                              color: Colors.white
                                                  .withOpacity(0.5),
                                              child: const Center(
                                                child: Icon(Icons.broken_image,
                                                    color: Colors.white),
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Style Label - Centered Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color5.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.brush_rounded,
                                            size: 20, color: color5),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.styleName,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Journal Entry
                                  const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Journal Entry",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      journalText,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  Divider(
                                      color: Colors.white.withOpacity(0.6),
                                      thickness: 1),
                                  const SizedBox(height: 8),

                                  // Date Footer
                                  Text(
                                    "Created on $dateStr",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Buttons
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      // Try Again Button
                      Expanded(
                        child: TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "Try Again",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Save Button (White Pill)
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: (!_isSaving &&
                                    widget.styledImageBytes != null)
                                ? _saveAndComplete
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: color5, // Serenity text color
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: _isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: color5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.check_rounded),
                                      SizedBox(width: 8),
                                      Text(
                                        "Save to Album",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}