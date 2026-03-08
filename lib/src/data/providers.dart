import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movie.dart';
import 'movie_repository.dart';

final movieRepositoryProvider = Provider<MovieRepository>((ref) {
  return const MovieRepository();
});

final moviesProvider = Provider<List<Movie>>((ref) {
  return ref.watch(movieRepositoryProvider).fetchTrending();
});

class PurchasedMoviesNotifier extends StateNotifier<Set<String>> {
  PurchasedMoviesNotifier() : super(<String>{});

  void unlock(String movieId) {
    state = {...state, movieId};
  }
}

final purchasedMoviesProvider =
    StateNotifierProvider<PurchasedMoviesNotifier, Set<String>>((ref) {
  return PurchasedMoviesNotifier();
});

enum PlaybackQualityPreference { auto, dataSaver, balanced, high }

class PlaybackPreferences {
  const PlaybackPreferences({
    required this.dataSaverEnabled,
    required this.quality,
  });

  final bool dataSaverEnabled;
  final PlaybackQualityPreference quality;

  PlaybackPreferences copyWith({
    bool? dataSaverEnabled,
    PlaybackQualityPreference? quality,
  }) {
    return PlaybackPreferences(
      dataSaverEnabled: dataSaverEnabled ?? this.dataSaverEnabled,
      quality: quality ?? this.quality,
    );
  }
}

class PlaybackPreferencesNotifier extends StateNotifier<PlaybackPreferences> {
  PlaybackPreferencesNotifier()
      : super(
          const PlaybackPreferences(
            dataSaverEnabled: true,
            quality: PlaybackQualityPreference.auto,
          ),
        );

  void setDataSaver(bool enabled) {
    state = state.copyWith(dataSaverEnabled: enabled);
  }

  void setQuality(PlaybackQualityPreference quality) {
    state = state.copyWith(quality: quality);
  }
}

final playbackPreferencesProvider =
    StateNotifierProvider<PlaybackPreferencesNotifier, PlaybackPreferences>((ref) {
  return PlaybackPreferencesNotifier();
});
