import 'package:flutter/material.dart';
import '../../modals/photo_viewer_modal.dart';

class PhotosPage extends StatelessWidget {
  final String albumTitle;

  const PhotosPage({super.key, required this.albumTitle});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA: Generate 15 fake image URLs
    final List<String> photos = List.generate(
      15, 
      (index) => "https://picsum.photos/400?random=$index"
    );

    return Scaffold(
      appBar: AppBar(title: Text(albumTitle)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 photos across
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              // Open the Viewer we just created
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PhotoViewerModal(
                    galleryItems: photos,
                    initialIndex: index,
                  ),
                ),
              );
            },
            child: Container(
              color: Colors.grey[200],
              child: Image.network(
                photos[index],
                fit: BoxFit.cover,
                errorBuilder: (_,__,___) => const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }
}