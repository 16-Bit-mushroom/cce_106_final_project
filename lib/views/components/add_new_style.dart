import 'package:cce_106_final_project/views/selection/image_selection.dart';
import 'package:flutter/material.dart';

class AddNewStyleCard extends StatelessWidget {
  const AddNewStyleCard({super.key});

  @override
  Widget build(BuildContext context) {
    // InkWell provides the ripple effect on tap
    return InkWell(
      onTap: () {
        // In MVC, this would call:
        // controller.onAddNewStyleTapped();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImageSelectionScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12), // Match the Container's border
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Using a dashed border is also a common, nice touch
          border: Border.all(
            color: Colors.blueGrey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your "Add button"
            Icon(
              Icons.add_circle,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            // Your "Text"
            Text(
              "Style New Photo",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}