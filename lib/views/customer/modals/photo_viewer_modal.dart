import 'package:flutter/material.dart';

class PhotoViewerModal extends StatefulWidget {
  final List<String> galleryItems;
  final int initialIndex;

  const PhotoViewerModal({
    super.key, 
    required this.galleryItems, 
    this.initialIndex = 0
  });

  @override
  State<PhotoViewerModal> createState() => _PhotoViewerModalState();
}

class _PhotoViewerModalState extends State<PhotoViewerModal> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text("${_currentIndex + 1} / ${widget.galleryItems.length}", 
          style: const TextStyle(color: Colors.white)),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.galleryItems.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          // InteractiveViewer enables Pinch-to-Zoom
          return InteractiveViewer(
            panEnabled: true, 
            minScale: 0.5,
            maxScale: 4, 
            child: Center(
              child: Image.network(
                widget.galleryItems[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, event) {
                  if (event == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}