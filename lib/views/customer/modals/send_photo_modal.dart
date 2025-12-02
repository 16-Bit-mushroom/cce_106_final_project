import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import '../../controllers/request_controller.dart'; 

class SendPhotoModal extends StatefulWidget {
  final List<XFile> selectedImages;

  const SendPhotoModal({super.key, required this.selectedImages});

  @override
  State<SendPhotoModal> createState() => _SendPhotoModalState();
}

class _SendPhotoModalState extends State<SendPhotoModal> {
  final TextEditingController _descController = TextEditingController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("New Request (${widget.selectedImages.length} photos)", 
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          
          const Divider(),
          
          // Image Preview Grid
          Expanded(
            child: GridView.builder(
              itemCount: widget.selectedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(widget.selectedImages[index].path),
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Description Input
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: "Add instructions (optional)",
              border: OutlineInputBorder(),
              hintText: "e.g., Please make these look vintage..."
            ),
            maxLines: 3,
          ),

          const SizedBox(height: 20),

          // Send Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: _isUploading ? null : _submitRequest,
              child: _isUploading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Confirm & Send", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _submitRequest() async {
    setState(() => _isUploading = true);
    
    // Call your controller here
    // await RequestController().createRequest(
    //   files: widget.selectedImages, 
    //   description: _descController.text
    // );

    // Mock delay for visualization
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isUploading = false);
      Navigator.pop(context); // Close modal
      
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Photos sent to service successfully!')),
      );
    }
  }
}