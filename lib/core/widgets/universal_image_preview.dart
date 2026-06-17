import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UniversalImagePreview extends StatelessWidget {
  final String imagePath;
  final Uint8List? imageBytes;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;

  const UniversalImagePreview({
    super.key,
    required this.imagePath,
    this.imageBytes,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      if (imageBytes != null && imageBytes!.isNotEmpty) {
        return Image.memory(
          imageBytes!,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      }
      if (imagePath.isNotEmpty) {
        return Image.network(
          imagePath,
          fit: fit,
          errorBuilder: errorBuilder,
        );
      }
    } else {
      if (imagePath.isNotEmpty) {
        return Image.file(
          io.File(imagePath),
          fit: fit,
          errorBuilder: errorBuilder,
        );
      }
    }

    return errorBuilder != null
        ? errorBuilder!(context, 'No image source provided', null)
        : Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 50, color: Colors.grey),
          );
  }
}
