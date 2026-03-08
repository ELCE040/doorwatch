import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../data/movie.dart';
import '../../data/providers.dart';

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, required this.movieId});

  final String movieId;

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends ConsumerState<PlayerPage>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _showOverlay = true;
  Timer? _overlayTimer;
  StreamVariant? _activeStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayTimer?.cancel();
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  Future<void> _initialize() async {
    final movie = _findMovie();
    final unlocked = ref.read(purchasedMoviesProvider).contains(widget.movieId);

    if (movie == null || !unlocked) {
      setState(() {
        _error = movie == null
            ? 'Movie not found.'
            : 'Please complete payment before watching.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final order = _buildStreamOrder(movie, ref.read(playbackPreferencesProvider));

    for (final stream in order) {
      final success = await _tryInitializeStream(stream);
      if (success) {
        _activeStream = stream;
        if (mounted) {
          setState(() => _isLoading = false);
          _scheduleOverlayHide();
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _error =
          'Unable to start stream right now. We tried multiple quality levels automatically. Please retry.';
    });
  }

  Future<bool> _tryInitializeStream(StreamVariant stream) async {
    final previous = _controller;
    previous?.removeListener(_onVideoTick);
    await previous?.dispose();

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(stream.url));
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      controller.addListener(_onVideoTick);
      if (!mounted) {
        await controller.dispose();
        return false;
      }
      setState(() {
        _controller = controller;
      });
      return true;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  List<StreamVariant> _buildStreamOrder(Movie movie, PlaybackPreferences preferences) {
    final sorted = [...movie.streams]..sort((a, b) => a.bitrateKbps.compareTo(b.bitrateKbps));

    switch (preferences.quality) {
      case PlaybackQualityPreference.dataSaver:
        return sorted;
      case PlaybackQualityPreference.balanced:
        if (sorted.length < 3) return sorted;
        return [sorted[1], sorted[0], sorted[2]];
      case PlaybackQualityPreference.high:
        return sorted.reversed.toList();
      case PlaybackQualityPreference.auto:
        if (preferences.dataSaverEnabled) {
          return sorted;
        }
        if (sorted.length < 3) {
          return sorted.reversed.toList();
        }
        return [sorted[1], sorted[2], sorted[0]];
    }
  }

  void _onVideoTick() {
    if (!mounted || _controller == null) return;
    final value = _controller!.value;

    if (value.hasError) {
      setState(() {
        _error = 'Video error: ${value.errorDescription ?? 'unknown'}';
      });
    }
  }

  Movie? _findMovie() {
    final movies = ref.read(moviesProvider);
    for (final movie in movies) {
      if (movie.id == widget.movieId) return movie;
    }
    return null;
  }

  void _toggleOverlay() {
    setState(() => _showOverlay = !_showOverlay);
    if (_showOverlay) {
      _scheduleOverlayHide();
    }
  }

  void _scheduleOverlayHide() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final movie = _findMovie();

    return Scaffold(
      appBar: AppBar(
        title: Text(movie?.title ?? 'Playback'),
        actions: [
          IconButton(
            tooltip: 'Retry stream',
            onPressed: () => unawaited(_initialize()),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => unawaited(_initialize()),
                child: const Text('Try again'),
              ),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Back to catalog'),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleOverlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
          if (_showOverlay)
            _PlayerOverlay(
              controller: controller,
              streamLabel: _activeStream?.label ?? 'Auto',
            ),
        ],
      ),
    );
  }
}

class _PlayerOverlay extends StatelessWidget {
  const _PlayerOverlay({
    required this.controller,
    required this.streamLabel,
  });

  final VideoPlayerController controller;
  final String streamLabel;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;

    return Container(
      color: Colors.black38,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Chip(label: Text('Stream: $streamLabel')),
          ),
          if (value.isBuffering)
            const LinearProgressIndicator(
              minHeight: 2,
            ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                },
                icon: Icon(value.isPlaying ? Icons.pause_circle : Icons.play_circle),
              ),
              Expanded(
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Color(0xFF9FA8DA),
                    bufferedColor: Colors.white24,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(value.position)),
              Text(_format(value.duration)),
            ],
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$mm:$ss';
  }
}
