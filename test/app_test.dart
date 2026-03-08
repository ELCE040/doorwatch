import 'package:doorwatch/src/core/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('app shell renders title', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: DoorWatchApp()));
    await tester.pumpAndSettle();

    expect(find.text('DoorWatch Movies'), findsOneWidget);
  });
}
