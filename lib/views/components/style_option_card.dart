import 'package:flutter/material.dart';

class StyleOptionCard extends StatelessWidget {
  final String styleName;
  final bool isSelected;
  final VoidCallback onTap;
  // final String? stylePreviewUrl; // For displaying a small preview image

  const StyleOptionCard({
    super.key,
    required this.styleName,
    this.isSelected = false,
    required this.onTap,
    // this.stylePreviewUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: isSelected ? 8 : 4, // Higher elevation when selected
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: Theme.of(context).primaryColor, width: 3) // Highlight border when selected
            : BorderSide.none,
      ),
      color: Theme.of(context).cardColor, // Use theme color
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.blueGrey.shade700, // Placeholder color for style preview
                child: isSelected
                    ? Icon(Icons.check_circle, size: 40, color: Theme.of(context).primaryColor)
                    : Icon(Icons.brush, size: 40, color: Colors.grey.shade500),
                // In a real app, you'd use Image.network or Image.asset here
                // if (stylePreviewUrl != null)
                //   Image.network(stylePreviewUrl!, fit: BoxFit.cover)
                // else
                //   Center(child: Icon(Icons.brush, size: 40, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                styleName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Theme.of(context).primaryColor : const Color.fromARGB(255, 94, 62, 97),
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