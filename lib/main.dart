import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/theme.dart';
import 'core/router.dart';
import 'firebase_options.dart';
import 'providers/config_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/stats_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock landscape orientation on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final container = ProviderContainer();

  bool firebaseAvailable = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
    
    // Initialize MobileAds
    await MobileAds.instance.initialize();
  } catch (e, stack) {
    debugPrint('Firebase/Ads init failed, running in simulation mode: $e\n$stack');
  }

  // Update ConfigNotifier state
  container.read(configProvider.notifier).setFirebaseAvailable(firebaseAvailable);

  // Initialize notifications if Firebase is available
  if (firebaseAvailable) {
    try {
      await container.read(notificationProvider.notifier).initialize();
    } catch (e, stack) {
      debugPrint('Failed to initialize notifications on startup: $e\n$stack');
    }
  }

  runApp(
    ProviderScope(
      // ignore: deprecated_member_use
      parent: container,
      child: const ThreeOfSpadesApp(),
    ),
  );
}

class ThreeOfSpadesApp extends ConsumerWidget {
  const ThreeOfSpadesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kaali Ki Teeggi (Three of Spades)',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(statsProvider).when(
        data: (stats) => Locale(stats.languageCode),
        loading: () => const Locale('en'),
        error: (_, err) => const Locale('en'),
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameTheme.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: GameTheme.neonCyan,
          secondary: GameTheme.neonPink,
          surface: GameTheme.darkBackground,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      ),
      routerConfig: router,
    );
  }
}
