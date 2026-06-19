import 'dart:convert';
import 'package:flutter/material.dart';

class AvatarUtils {
  /// Checks if the avatar string is a Base64 Data URI.
  static bool isBase64(String? avatar) {
    if (avatar == null) return false;
    return avatar.startsWith('data:image/');
  }

  /// Parses a Base64 Data URI or normal URL into an [ImageProvider].
  static ImageProvider? getImageProvider(String? avatar) {
    if (avatar == null || avatar.isEmpty) return null;

    if (isBase64(avatar)) {
      try {
        final commaIndex = avatar.indexOf(',');
        if (commaIndex != -1) {
          final base64String = avatar.substring(commaIndex + 1);
          final bytes = base64Decode(base64String);
          return MemoryImage(bytes);
        }
      } catch (e) {
        debugPrint('Error decoding base64 avatar: $e');
      }
    }

    return NetworkImage(avatar);
  }

  /// Renders a Widget displaying the avatar.
  static Widget buildAvatarWidget({
    required String? avatar,
    required double size,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
  }) {
    final defaultPlaceholder = placeholder ?? Icon(
      Icons.person,
      size: size * 0.6,
      color: const Color(0xFFB09080),
    );

    if (avatar == null || avatar.isEmpty) {
      return defaultPlaceholder;
    }

    if (isBase64(avatar)) {
      try {
        final commaIndex = avatar.indexOf(',');
        if (commaIndex != -1) {
          final base64String = avatar.substring(commaIndex + 1);
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            width: size,
            height: size,
            fit: fit,
            errorBuilder: (_, _, _) => defaultPlaceholder,
          );
        }
      } catch (e) {
        debugPrint('Error decoding base64 avatar widget: $e');
      }
      return defaultPlaceholder;
    }

    return Image.network(
      avatar,
      width: size,
      height: size,
      fit: fit,
      errorBuilder: (_, _, _) => defaultPlaceholder,
    );
  }
}
