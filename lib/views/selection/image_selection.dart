import 'package:cce_106_final_project/views/components/selection_option_card.dart';
import 'package:cce_106_final_project/views/style_selection/style_selection_scree.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageSelectionScreen extends StatelessWidget {
  const ImageSelectionScreen({super.key});

  // --- Web-Only Image Picking ---
  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // For web, this opens the file explorer
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        debugPrint("Image selected: ${image.name}");
        
        // Read image as bytes for web
        final bytes = await image.readAsBytes();
        
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => StyleSelectionScreen(
              imageBytes: bytes,
              // imageName: image.name, // Optional: pass the file name
            ),
          ),
        );
      } else {
        debugPrint("No image selected");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      _showErrorSnackBar(context, "Failed to pick image: ${e.toString()}");
    }
  }

  // Optional: Web camera support
  Future<void> _takePhotoWithCamera(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        debugPrint("Photo taken: ${photo.name}");
        
        final bytes = await photo.readAsBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StyleSelectionScreen(
              imageBytes: bytes,
              // imageName: photo.name,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error with camera: $e");
      _showErrorSnackBar(context, "Camera not available: ${e.toString()}");
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Photo Source"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera option (works on web if browser supports it)
              SelectionOptionCard(
                icon: Icons.camera_alt_outlined,
                title: "Take Photo",
                onTap: () {
                  _takePhotoWithCamera(context);
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  "Or",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Gallery option - this will open Windows file explorer
              SelectionOptionCard(
                icon: Icons.photo_library_outlined,
                title: "Choose from Gallery",
                onTap: () {
                  _pickImageFromGallery(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}