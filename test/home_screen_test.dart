import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dr_last_claim': DateTime.now().toIso8601String().substring(0, 10),
      'dr_consecutive_days': 1,
    });
  });

  testWidgets('StatsNotifier loads default stats', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    late StatsNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final stats = ref.watch(statsProvider);
            notifier = ref.read(statsProvider.notifier);
            return stats.when(
              data: (s) => Text(s.name, textDirection: TextDirection.ltr),
              loading: () => const Text('loading', textDirection: TextDirection.ltr),
              error: (e, _) => const Text('error', textDirection: TextDirection.ltr),
            );
          },
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Guest Player'), findsOneWidget);
    expect(notifier, isNotNull);
  });

  testWidgets('StatsNotifier can set AI difficulty', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    late StatsNotifier notifier;

    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final stats = ref.watch(statsProvider);
            notifier = ref.read(statsProvider.notifier);
            return stats.when(
              data: (s) => Text(s.aiDifficulty.name, textDirection: TextDirection.ltr),
              loading: () => const Text('loading', textDirection: TextDirection.ltr),
              error: (e, _) => const Text('error', textDirection: TextDirection.ltr),
            );
          },
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    // Default is medium
    expect(find.text('medium'), findsOneWidget);

    // Change to hard
    await notifier.setAiDifficulty(AiDifficulty.hard);
    await tester.pump();
    expect(find.text('hard'), findsOneWidget);
  });

  testWidgets('AiDifficulty values are accessible', (WidgetTester tester) async {
    expect(AiDifficulty.easy.name, equals('easy'));
    expect(AiDifficulty.medium.name, equals('medium'));
    expect(AiDifficulty.hard.name, equals('hard'));
  });
}
