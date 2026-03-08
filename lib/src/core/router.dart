import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/catalog_page.dart';
import '../features/payment/payment_page.dart';
import '../features/player/player_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const CatalogPage(),
      ),
      GoRoute(
        path: '/pay/:movieId',
        builder: (context, state) {
          return PaymentPage(movieId: state.pathParameters['movieId'] ?? '');
        },
      ),
      GoRoute(
        path: '/watch/:movieId',
        builder: (context, state) {
          return PlayerPage(movieId: state.pathParameters['movieId'] ?? '');
        },
      ),
    ],
  );
});
