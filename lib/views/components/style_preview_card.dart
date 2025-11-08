import 'package:flutter/material.dart';

class StylePreviewCard extends StatelessWidget {
  final String styleName;
  // final String imageUrl; // You would add this

  const StylePreviewCard({
    super.key,
    required this.styleName,
    // required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Card provides the elevation and rounded corners
    return Card(
      clipBehavior: Clip.antiAlias, // Ensures image corners are rounded
      elevation: 3,
      child: InkWell(
        onTap: () {
          // In MVC, this would call:
          // controller.onStyleTapped(styleName);
          print("Tapped on $styleName collection");
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // This is the image placeholder
            Expanded(
              child: Container(
                color: Colors.grey[200],
                // In a real app, you'd use:
                // Image.network(
                //   imageUrl,
                //   fit: BoxFit.cover,
                // ),
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: Colors.grey[500],
                ),
              ),
            ),
            // This is the text label
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                styleName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}