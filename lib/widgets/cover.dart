import 'package:flutter/material.dart';

import '../theme.dart';

/// Capa do álbum, com um degradê bonito quando não há imagem.
class Cover extends StatelessWidget {
  final String? url;
  final double size;
  final double radius;
  const Cover({super.key, this.url, required this.size, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const SweepGradient(colors: [
          AppColors.cool,
          AppColors.hot,
          AppColors.warm,
          AppColors.cool,
        ]),
      ),
      child: Icon(Icons.music_note,
          color: Colors.white70, size: size * .4),
    );
    if (url == null || url!.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.network(url!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback),
    );
  }
}
