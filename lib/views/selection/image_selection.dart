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

  // Matches the Stability Service list exactly
  final List<String> _styles = [
    "Anime",
    "Cyberpunk",
    "Cartoon",
    "Sketch",
    "3D Model",
  ];
  String _selectedStyle = "Anime"; // Default

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      imageQuality: 80,
    );

    if (image == null) return;

    if (mounted) {
      _showDetailsDialog(image);
    }
  }

  void _showDetailsDialog(XFile image) {
    _journalController.clear();
    // Reset style to default each time
    setState(() => _selectedStyle = _styles.first);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // We use a StatefulBuilder specifically for the dialog to handle
        // the dropdown state updating *inside* the dialog.
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Customize Request"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Style Selection
                    const Text(
                      "Choose a Style:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStyle,
                          isExpanded: true,
                          items: _styles.map((String style) {
                            return DropdownMenuItem<String>(
                              value: style,
                              child: Text(style),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setStateDialog(() {
                              _selectedStyle = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Journal Entry
                    const Text(
                      "Journal Entry:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _journalController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "e.g., 'Summer trip to Bohol, 2025'",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _uploadRequest(image, _journalController.text.trim());
                  },
                  child: const Text("Send Request"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _uploadRequest(XFile image, String journalText) async {
    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'raw/$userId/$fileName';

      await supabase.storage
          .from('photos')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      await supabase.from('requests').insert({
        'user_id': userId,
        'original_image_path': filePath,
        'style_type': _selectedStyle, // <--- SAVING THE SELECTED STYLE
        'status': 'pending',
        'notes': journalText,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request sent successfully!')),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text("New Request"), elevation: 0),
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
                  "Choose a style and add a memory to your photo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),
                SelectionOptionCard(
                  icon: Icons.camera_alt_outlined,
                  title: "Take Photo",
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(height: 20),
                SelectionOptionCard(
                  icon: Icons.photo_library_outlined,
                  title: "Choose from Gallery",
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
