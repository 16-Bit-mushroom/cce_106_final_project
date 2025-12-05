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
    // Extract journal notes safely
    final journalText =
        widget.requestData?['notes'] ?? "No journal entry provided.";
    final dateStr = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

    return Scaffold(
      appBar: AppBar(
        title: const Text("Album Preview"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      // 1. Main Background color (Light Grey for the "table" surface)
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                // 2. The "Paper" Card
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ), // Max width for desktop
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1), // Cream/Paper color
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 3. Double Border Container for the Image
                      Container(
                        padding: const EdgeInsets.all(
                          4,
                        ), // Gap between border and image
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF8D6E63),
                            width: 1,
                          ), // Brownish border
                        ),
                        child: widget.styledImageBytes != null
                            ? Image.memory(
                                widget.styledImageBytes!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 300,
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              ),
                      ),

                      const SizedBox(height: 24),

                      // 4. Journal Text Area
                      Text(
                        journalText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Serif', // Uses system serif font
                          color: Color(0xFF4E342E), // Dark Brown text
                          height: 1.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 5. Decorative Footer / Date
                      Divider(
                        color: const Color(0xFF8D6E63).withOpacity(0.5),
                        indent: 40,
                        endIndent: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Created on $dateStr"
                            .toUpperCase(), // <--- FIX APPLIED HERE
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color(0xFF8D6E63).withOpacity(0.8),
                          letterSpacing: 1.5,
                          // uppercase: true, <--- REMOVED THIS LINE
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Try Again'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: (!_isSaving && widget.styledImageBytes != null)
                        ? _saveAndComplete
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63), // Match theme
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.print),
                    label: const Text("Print & Complete"),
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
