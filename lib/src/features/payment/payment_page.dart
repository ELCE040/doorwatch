import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/movie.dart';
import '../../data/providers.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key, required this.movieId});

  final String movieId;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final movie = _findMovie(ref, widget.movieId);
    final preferences = ref.watch(playbackPreferencesProvider);

    if (movie == null) {
      return const _UnknownMovie();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Secure Pay‑Per‑View')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(movie.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              movie.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            _PaymentSummary(price: movie.price),
            const SizedBox(height: 20),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '4242 4242 4242 4242',
              ),
              validator: (value) {
                final digits = value?.replaceAll(' ', '') ?? '';
                if (digits.length < 16) return 'Enter a valid card number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'MM/YY'),
                    validator: (value) {
                      if ((value ?? '').trim().length < 5) return 'Invalid expiry';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'CVV'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if ((value ?? '').trim().length < 3) return 'Invalid CVV';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SwitchListTile.adaptive(
              title: const Text('Optimize internet usage (adaptive fallback)'),
              subtitle: const Text('Uses smaller streams first on weak networks.'),
              value: preferences.dataSaverEnabled,
              onChanged: (value) {
                ref.read(playbackPreferencesProvider.notifier).setDataSaver(value);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PlaybackQualityPreference>(
              value: preferences.quality,
              decoration: const InputDecoration(labelText: 'Preferred quality'),
              items: const [
                DropdownMenuItem(
                  value: PlaybackQualityPreference.auto,
                  child: Text('Auto (recommended)'),
                ),
                DropdownMenuItem(
                  value: PlaybackQualityPreference.dataSaver,
                  child: Text('Data saver'),
                ),
                DropdownMenuItem(
                  value: PlaybackQualityPreference.balanced,
                  child: Text('Balanced'),
                ),
                DropdownMenuItem(
                  value: PlaybackQualityPreference.high,
                  child: Text('High'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(playbackPreferencesProvider.notifier).setQuality(value);
                }
              },
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      setState(() => _isProcessing = true);
                      await Future<void>.delayed(const Duration(seconds: 2));
                      if (!mounted) return;

                      ref.read(purchasedMoviesProvider.notifier).unlock(movie.id);
                      setState(() => _isProcessing = false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Payment successful. Movie unlocked!')),
                      );
                      context.go('/watch/${movie.id}');
                    },
              icon: _isProcessing
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.lock_open_rounded),
              label: Text(_isProcessing
                  ? 'Processing payment...'
                  : 'Pay ${NumberFormat.simpleCurrency().format(movie.price)} & Watch'),
            ),
          ],
        ),
      ),
    );
  }

  Movie? _findMovie(WidgetRef ref, String id) {
    for (final movie in ref.read(moviesProvider)) {
      if (movie.id == id) return movie;
    }
    return null;
  }
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.price});

  final double price;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _row('Movie access', price),
            const SizedBox(height: 10),
            _row('Platform fee', 0),
            const Divider(height: 26),
            _row('Total today', price, bold: true),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('No subscription. One payment per movie.'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, double amount, {bool bold = false}) {
    final style = TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w400);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style),
        Text(NumberFormat.simpleCurrency().format(amount), style: style),
      ],
    );
  }
}

class _UnknownMovie extends StatelessWidget {
  const _UnknownMovie();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movie not found')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to home'),
        ),
      ),
    );
  }
}
