import 'package:flutter/material.dart';
import 'style_preview_card.dart';

class StyleGrid extends StatelessWidget {
  const StyleGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // This is the "Container" holding your grid.
    // GridView.builder is the correct widget for performance.
    return GridView.builder(
      // This delegate controls the layout
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // As seen in your sketch
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8, // Adjust ratio of width to height
      ),
      // In a real app, this count would come from your Supabase query
      itemCount: 9, // Using 9 as in your sketch
      itemBuilder: (context, index) {
        // Here you would pass in real data
        // For now, we'll just alternate styles for the example
        final style = (index % 3 == 0) ? "Anime" : "Oil Painting";
        
        // Component 5: The individual card
        return StylePreviewCard(
          styleName: style,
          // You would also pass the image URL here
        );
      },
    );
  }
}