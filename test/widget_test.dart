import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/main.dart';

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ThreeOfSpadesApp(),
      ),
    );

    expect(find.text('THREE OF SPADES'), findsOneWidget);
    expect(find.text('KAALI KI TEEGGI'), findsOneWidget);

    // Let the splash screen timer complete to avoid pending timer assertion
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();
  });
}
