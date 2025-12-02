import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cce_106_final_project/views/components/selection_option_card.dart';

class ImageSelectionScreen extends StatefulWidget {
  const ImageSelectionScreen({super.key});

  @override
  State<ImageSelectionScreen> createState() => _ImageSelectionScreenState();
}

class _ImageSelectionScreenState extends State<ImageSelectionScreen> {
  bool _isUploading = false;
  final TextEditingController _journalController = TextEditingController();

  // 1. First, pick the image
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 80,
    );

    if (image == null) return;

    // 2. Instead of uploading immediately, show the Journal Dialog
    if (mounted) {
      _showJournalDialog(image);
    }
  }

  // 3. The "Cutting Corners" Input Screen (A Dialog)
  void _showJournalDialog(XFile image) {
    _journalController.clear(); // Reset text

    showDialog(
      context: context,
      barrierDismissible: false, // Force them to choose or cancel
      builder: (context) => AlertDialog(
        title: const Text("Add Journal Entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Write a short caption or memory for this photo:"),
            const SizedBox(height: 16),
            TextField(
              controller: _journalController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "e.g., 'Summer trip to Bohol, 2025'",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _uploadRequest(image, _journalController.text.trim()); // Proceed
            },
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }

  // 4. The Actual Upload Logic
  Future<void> _uploadRequest(XFile image, String journalText) async {
    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'raw/$userId/$fileName';

      // Upload Image
      await supabase.storage
          .from('photos')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      // Insert DB Record with the Journal Text (notes)
      await supabase.from('requests').insert({
        'user_id': userId,
        'original_image_path': filePath,
        'style_type': 'New Request',
        'status': 'pending',
        'notes': journalText, // <--- SAVING THE JOURNAL ENTRY HERE
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.pop(context); // Go back to Dashboard
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Request"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 80,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Upload a photo to style",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "You'll be asked to add a journal entry after selecting a photo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Option 1: Camera
                SelectionOptionCard(
                  icon: Icons.camera_alt_outlined,
                  title: "Take Photo",
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 20),

                // Option 2: Gallery
                SelectionOptionCard(
                  icon: Icons.photo_library_outlined,
                  title: "Choose from Gallery",
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Uploading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
}
