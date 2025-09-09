import 'dart:io';
import 'package:flutter/material.dart';

class BookCoverImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Color? backgroundColor;

  const BookCoverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = _buildPlaceholder(context);
    } else if (_isLocalPath(imageUrl)) {
      // 로컬 파일 이미지
      imageWidget = Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    } else {
      // 네트워크 이미지
      imageWidget = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            width: width,
            height: height,
            color: backgroundColor ?? Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            ),
          );
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
    return placeholder ??
        Container(
          width: width,
          height: height,
          color:
              backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.book_rounded,
            size:
                (width != null && height != null) ? (width! + height!) / 6 : 32,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        );
  }

  bool _isLocalPath(String imagePath) {
    return imagePath.startsWith('/') ||
        imagePath.startsWith('file://') ||
        (!imagePath.startsWith('http://') && !imagePath.startsWith('https://'));
  }
}
