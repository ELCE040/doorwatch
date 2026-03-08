import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../widgets/movie_card.dart';

class CatalogPage extends ConsumerWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movies = ref.watch(moviesProvider);
    final unlocked = ref.watch(purchasedMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DoorWatch Movies'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.high_quality_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Fast streaming • Low data usage mode • Pay only what you watch',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          for (final movie in movies)
            MovieCard(
              movie: movie,
              isUnlocked: unlocked.contains(movie.id),
              onTap: () {
                if (unlocked.contains(movie.id)) {
                  context.push('/watch/${movie.id}');
                } else {
                  context.push('/pay/${movie.id}');
                }
              },
            ),
        ],
      ),
    );
  }
}
