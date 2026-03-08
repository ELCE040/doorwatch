import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../data/movie.dart';

class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.isUnlocked,
  });

  final Movie movie;
  final VoidCallback onTap;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      color: Colors.white10,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    errorWidget: (context, _, __) => Container(
                      color: Colors.white10,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Chip(
                    avatar: Icon(
                      isUnlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded,
                      size: 16,
                    ),
                    label: Text(isUnlocked ? 'Unlocked' : 'Pay-to-watch'),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title, style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    '${movie.genre} • ${movie.durationLabel} • \$${movie.price.toStringAsFixed(2)}',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
