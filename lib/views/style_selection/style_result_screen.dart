import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StyleResultScreen extends StatefulWidget {
  final Uint8List? originalImageBytes;
  final Uint8List? styledImageBytes;
  final String styleName;
  // NEW: Accept request data so we know what to update in DB
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
    // 1. Validation
    if (widget.requestData == null || widget.styledImageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing request data or image.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final requestId = widget.requestData!['id'];
      // Create a unique filename for storage
      final fileName =
          'styled_${requestId}_${DateTime.now().millisecondsSinceEpoch}.png';
      final filePath = 'styled/$fileName';

      // 2. Upload Styled Image to Supabase Storage
      await Supabase.instance.client.storage
          .from('photos')
          .uploadBinary(
            filePath,
            widget.styledImageBytes!,
            fileOptions: const FileOptions(contentType: 'image/png'),
          );

      // 3. Update Request Record (Status -> Completed)
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
          const SnackBar(
            content: Text('Saved successfully! Request Completed.'),
          ),
        );
        // Pop back to Dashboard (remove Result AND Selection screens)
        Navigator.of(context)
          ..pop()
          ..pop();
      }
    } catch (e) {
      print("Save Error: $e");
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
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.styleName} Style Result"),
        // Removed the top download button to focus on the main action below
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
                      imageBytes: widget.originalImageBytes,
                      title: 'Original',
                      borderColor: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Styled Image
                  Expanded(
                    child: _buildImageCard(
                      imageBytes: widget.styledImageBytes,
                      title: 'Styled (${widget.styleName})',
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
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Try Another Style'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (widget.styledImageBytes != null && !_isSaving)
                        ? _saveAndComplete
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Save & Complete'),
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
              style: TextStyle(fontWeight: FontWeight.bold, color: borderColor),
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
                        child: Image.memory(imageBytes, fit: BoxFit.cover),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image,
                              size: 40,
                              color: Colors.grey,
                            ),
                            const Text(
                              'No Image',
                              style: TextStyle(color: Colors.grey),
                            ),
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
}
