import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme.dart';

class AvatarImage extends StatelessWidget {
  final String avatarPath;
  final double size;
  final BoxFit fit;

  const AvatarImage({
    super.key,
    required this.avatarPath,
    this.size = 80,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final int cacheSize = (size * pixelRatio).round();

    if (avatarPath.isEmpty) {
      return Image.asset(
        'assets/images/guest_avatar.png',
        fit: fit,
        width: size,
        height: size,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
      );
    }

    // Check if it is Base64 data (custom avatar)
    if (!avatarPath.startsWith('http') && !avatarPath.startsWith('assets/')) {
      try {
        final decodedBytes = base64Decode(avatarPath);
        return Image.memory(
          decodedBytes,
          fit: fit,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            'assets/images/guest_avatar.png',
            fit: fit,
            width: size,
            height: size,
            cacheWidth: cacheSize,
            cacheHeight: cacheSize,
          ),
        );
      } catch (e) {
        // Fallback if decoding fails
        return Image.asset(
          'assets/images/guest_avatar.png',
          fit: fit,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
        );
      }
    }

    if (avatarPath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: avatarPath,
        fit: fit,
        width: size,
        height: size,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: GameTheme.neonCyan, strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/images/guest_avatar.png',
          fit: fit,
          width: size,
          height: size,
          cacheWidth: cacheSize,
          cacheHeight: cacheSize,
        ),
      );
    }

    return Image.asset(
      avatarPath,
      fit: fit,
      width: size,
      height: size,
      cacheWidth: cacheSize,
      cacheHeight: cacheSize,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/guest_avatar.png',
        fit: fit,
        width: size,
        height: size,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
      ),
    );
  }
}
