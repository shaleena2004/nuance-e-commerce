import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CustomImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imagePath.startsWith('data:image') || imagePath.startsWith('data:application')) {
      try {
        final commaIndex = imagePath.indexOf(',');
        final base64Str = commaIndex != -1 ? imagePath.substring(commaIndex + 1) : imagePath;
        final Uint8List bytes = base64Decode(base64Str.trim());
        imageWidget = Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        );
      } catch (e) {
        imageWidget = _buildPlaceholder(context);
      }
    } else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      imageWidget = Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF222226)
                : const Color(0xFFEAEAEA),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color: isDark ? const Color(0xFF26262B) : const Color(0xFFECECEC),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? Colors.white38 : Colors.black26,
          size: 32,
        ),
      ),
    );
  }
}
