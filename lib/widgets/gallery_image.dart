import 'package:flutter/material.dart';
import '../core/constants.dart';

class GalleryImage extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const GalleryImage({super.key, required this.imagePath, this.onTap});

  @override
  State<GalleryImage> createState() => _GalleryImageState();
}

class _GalleryImageState extends State<GalleryImage> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          child: AnimatedScale(
            scale: _hovering ? 1.06 : 1.0,
            duration: AppConstants.animFast,
            curve: Curves.easeOut,
            child: Image.asset(
              widget.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
