import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:three_of_spades_flutter/screens/home_screen.dart';
import 'package:three_of_spades_flutter/providers/stats_provider.dart';
import 'package:three_of_spades_flutter/providers/config_provider.dart';
import 'package:three_of_spades_flutter/l10n/app_localizations.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:three_of_spades_flutter/providers/daily_reward_provider.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'dr_last_claim': DateTime.now().toIso8601String().substring(0, 10),
      'dr_consecutive_days': 1,
    });
  });
  testWidgets('HomeScreen renders correctly and displays stats', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    
    // Dismiss daily reward dialog if present
    if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(seconds: 1));
    }

    // Verify main components are present
    expect(find.text('Guest Player'), findsOneWidget);
    expect(find.text('5000 COINS'), findsOneWidget);
    
    // Verify bot card exists
    expect(find.text('Play vs Intelligent Bots'), findsOneWidget);
    
    // Check Settings button semantics
    final settingsIcon = find.byIcon(Icons.settings);
    expect(settingsIcon, findsOneWidget);
  });

  testWidgets('HomeScreen Settings Dialog opens and has language toggle', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statsProvider.overrideWith(() => StatsNotifier()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // Dismiss daily reward dialog if present
    if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(seconds: 1));
    }

    // Tap settings
    final settingsIcon = find.byIcon(Icons.settings);
    await tester.tap(settingsIcon);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify Settings dialog
    expect(find.text('SETTINGS'), findsWidgets);
    expect(find.text('Language'), findsWidgets);
    expect(find.text('English'), findsWidgets);
    
    // Verify Sound and Music toggles
    expect(find.text('Sound Effects'), findsOneWidget);
    expect(find.text('Background Music'), findsOneWidget);
  });
}
