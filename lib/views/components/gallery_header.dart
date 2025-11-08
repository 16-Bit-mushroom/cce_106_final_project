import 'package:flutter/material.dart';

class GalleryHeader extends StatelessWidget {
  const GalleryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Your Creations",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 24,
          // // FIX: Using a local asset image to avoid NetworkImageLoadException
          // // Make sure you have 'assets/images/user_avatar.png' and it's declared in pubspec.yaml
          // backgroundImage: const AssetImage('assets/images/user_avatar.png'),

          // You can also use a simple Icon as a fallback or placeholder
          child: Icon(Icons.person, size: 30, color: Colors.white),
          // backgroundColor: Colors.blueGrey,
        ),
      ],
    );
  }
}
