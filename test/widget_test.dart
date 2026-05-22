import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/main.dart';
import 'package:three_of_spades_flutter/widgets/glass_dialog.dart';

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

  group('GlassDialog', () {
    testWidgets('renders title, content and actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => GlassDialog(
                      title: 'Edit Name',
                      content: const Text('dialog content'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('SAVE'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('EDIT NAME'), findsOneWidget);
      expect(find.text('dialog content'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
      expect(find.text('SAVE'), findsOneWidget);
    });

    testWidgets('SAVE button is tappable even in constrained height', (WidgetTester tester) async {
      // Simulate a landscape-like small-height viewport (e.g. keyboard visible)
      tester.view.physicalSize = const Size(1024, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool saved = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => GlassDialog(
                      title: 'Edit Name',
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          6,
                          (i) => const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text('Row'),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            saved = true;
                          },
                          child: const Text('SAVE'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Scroll to the bottom of the dialog to find SAVE
      await tester.scrollUntilVisible(find.text('SAVE'), 50, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('SAVE'));
      await tester.pump();

      expect(saved, isTrue, reason: 'SAVE button should be tappable via scroll');
    });

    testWidgets('X button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => GlassDialog(
                      title: 'Settings',
                      content: const Text('settings content'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);

      // Tap the X close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsNothing);
    });
  });
}
