import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock landscape orientation on mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    const ProviderScope(
      child: ThreeOfSpadesApp(),
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
