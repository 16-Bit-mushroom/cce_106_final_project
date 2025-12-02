import 'package:flutter/material.dart';
import '../photos/photos_page.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // MOCK DATA
    final List<String> albums = ["Wedding", "Birthday", "Product Shoot", "Vacation", "Misc"];

    return Scaffold(
      appBar: AppBar(title: const Text("My Albums")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 columns
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          return InkWell(
onTap: () {
               // <--- UPDATE THIS SECTION
               Navigator.push(
                 context, 
                 MaterialPageRoute(
                   builder: (_) => PhotosPage(albumTitle: albums[index])
                 )
               );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album Cover (Placeholder)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage("https://picsum.photos/200"), // Random dummy image
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  albums[index],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text("12 items", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}