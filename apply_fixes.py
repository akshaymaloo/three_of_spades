import re

def fix_code():
    with open('lib/screens/home_screen.dart', 'r') as f:
        code = f.read()

    # 1. Add localization import
    if "import 'package:flutter_gen/gen_l10n/app_localizations.dart';" not in code:
        code = code.replace("import 'leaderboard_screen.dart';", "import 'leaderboard_screen.dart';\nimport 'package:flutter_gen/gen_l10n/app_localizations.dart';")

    # 2. Add language toggle in _showSettings
    language_toggle = """                      // Language toggle
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(AppLocalizations.of(context)?.language ?? 'Language', style: const TextStyle(color: GameTheme.textWhite)),
                        trailing: DropdownButton<String>(
                          value: stats.languageCode,
                          dropdownColor: GameTheme.darkBackground,
                          style: const TextStyle(color: GameTheme.neonCyan),
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'hi', child: Text('Hindi')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              ref.read(statsProvider.notifier).updateLanguage(val);
                            }
                          },
                        ),
                      ),
                      const Divider(color: Colors.white10),
                      // Sound toggle"""
    code = code.replace("// Sound toggle", language_toggle)

    # 3. Replace Bot Card Expanded -> Flexible & Add Semantics
    bot_card_old = """                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  ref.read(gameProvider.notifier).startNewGame();
                                },"""
    bot_card_new = """                            Flexible(
                              child: Semantics(
                                label: AppLocalizations.of(context)?.playVsIntelligentBots ?? 'Play vs Intelligent Bots',
                                button: true,
                                child: InkWell(
                                  onTap: () {
                                    ref.read(gameProvider.notifier).startNewGame();
                                  },"""
    code = code.replace(bot_card_old, bot_card_new)

    # Bot card end parens fixing
    bot_card_end_old = """                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),"""
    bot_card_end_new = """                                  ),
                                ),
                              ),
                            ),
                           ),
                          const SizedBox(height: 16),"""
    code = code.replace(bot_card_end_old, bot_card_end_new)

    # 4. _buildModeCard Semantics
    mode_card_old = """    return InkWell(
      onTap: enabled
          ? onTap
          : () {"""
    mode_card_new = """    return Semantics(
      label: title,
      button: true,
      child: InkWell(
        onTap: enabled
            ? onTap
            : () {"""
    code = code.replace(mode_card_old, mode_card_new)

    mode_card_end_old = """        ),
      ),
    );
  }
}"""
    mode_card_end_new = """        ),
      ),
     ),
    );
  }
}"""
    code = code.replace(mode_card_end_old, mode_card_end_new)

    # 5. Fix some basic strings with AppLocalizations
    code = code.replace("title: 'Settings',", "title: AppLocalizations.of(context)?.settings ?? 'Settings',")
    code = code.replace("title: const Text('Sound Effects'", "title: Text(AppLocalizations.of(context)?.soundEffects ?? 'Sound Effects'")
    code = code.replace("title: const Text('Background Music'", "title: Text(AppLocalizations.of(context)?.backgroundMusic ?? 'Background Music'")
    code = code.replace("title: const Text('Online Mode (Firebase)'", "title: Text(AppLocalizations.of(context)?.onlineModeFirebase ?? 'Online Mode (Firebase)'")
    code = code.replace("title: 'Reset Stats?'", "title: AppLocalizations.of(context)?.resetStatsTitle ?? 'Reset Stats?'")
    code = code.replace("title: 'Edit Name'", "title: AppLocalizations.of(context)?.editNameTitle ?? 'Edit Name'")
    
    code = code.replace("const Text('Play vs Intelligent Bots'", "Text(AppLocalizations.of(context)?.playVsIntelligentBots ?? 'Play vs Intelligent Bots'")
    code = code.replace("const Text(\n                                              'Practice your bidding strategies", "Text(\n                                              AppLocalizations.of(context)?.practiceBiddingDesc ?? 'Practice your bidding strategies")

    with open('lib/screens/home_screen.dart', 'w') as f:
        f.write(code)

if __name__ == '__main__':
    fix_code()
