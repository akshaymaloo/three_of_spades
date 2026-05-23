import re

def main():
    with open('lib/screens/home_screen.dart', 'r') as f:
        content = f.read()

    # Add localization import
    content = content.replace("import '../widgets/glass_dialog.dart';", "import '../widgets/glass_dialog.dart';\nimport 'package:flutter_gen/gen_l10n/app_localizations.dart';")

    # AppLocalizations helper
    content = content.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final l10n = AppLocalizations.of(context)!;")
    
    # Add Language Toggle in Settings
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
    content = content.replace("// Sound toggle", language_toggle)

    # In _showSettings, we need AppLocalizations.of(context)!
    content = content.replace("title: 'Settings',", "title: AppLocalizations.of(context)?.settings ?? 'Settings',")
    content = content.replace("const Text('Sound Effects'", "Text(AppLocalizations.of(context)?.soundEffects ?? 'Sound Effects'")
    content = content.replace("const Text('Background Music'", "Text(AppLocalizations.of(context)?.backgroundMusic ?? 'Background Music'")
    content = content.replace("const Text('Online Mode (Firebase)'", "Text(AppLocalizations.of(context)?.onlineModeFirebase ?? 'Online Mode (Firebase)'")
    content = content.replace("'Active (Needs Firebase setup)'", "AppLocalizations.of(context)?.onlineModeActive ?? 'Active (Needs Firebase setup)'")
    content = content.replace("'Simulation / Offline Only'", "AppLocalizations.of(context)?.onlineModeOffline ?? 'Simulation / Offline Only'")
    content = content.replace("'Switched to Online Mode! Needs Firebase config.'", "AppLocalizations.of(context)?.switchedOnlineMode ?? 'Switched to Online Mode! Needs Firebase config.'")
    content = content.replace("'Switched to Simulation Mode (Offline/Mock).'", "AppLocalizations.of(context)?.switchedOfflineMode ?? 'Switched to Simulation Mode (Offline/Mock).'")
    content = content.replace("const Text('Push Notifications'", "Text(AppLocalizations.of(context)?.pushNotifications ?? 'Push Notifications'")
    content = content.replace("const Text('Get room invites and updates'", "Text(AppLocalizations.of(context)?.pushNotificationsSubtitle ?? 'Get room invites and updates'")
    content = content.replace("title: 'Reset Stats?'", "title: AppLocalizations.of(context)?.resetStatsTitle ?? 'Reset Stats?'")
    content = content.replace("'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.'", "AppLocalizations.of(context)?.resetStatsBody ?? 'This will reset your coins back to 5,000 and wipe out your win history. This action is irreversible.'")
    content = content.replace("const Text('CANCEL'", "Text(AppLocalizations.of(context)?.cancel ?? 'CANCEL'")
    content = content.replace("const Text('RESET'", "Text(AppLocalizations.of(context)?.reset ?? 'RESET'")
    content = content.replace("Text('RESET GUEST STATS'", "Text(AppLocalizations.of(context)?.resetGuestStats ?? 'RESET GUEST STATS'")

    content = content.replace("title: 'Edit Name'", "title: AppLocalizations.of(context)?.editNameTitle ?? 'Edit Name'")
    content = content.replace("'Enter your alias:'", "AppLocalizations.of(context)?.editNameSubtitle ?? 'Enter your alias:'")
    content = content.replace("hintText: 'Alias'", "hintText: AppLocalizations.of(context)?.alias ?? 'Alias'")
    content = content.replace("const Text('SAVE'", "Text(AppLocalizations.of(context)?.save ?? 'SAVE'")

    content = content.replace("'${stats.coins.toString()} COINS'", "l10n.coins.replaceFirst('Coins', '').trim().isEmpty ? '${stats.coins.toString()} ${l10n.coins}' : '${stats.coins.toString()} ${l10n.coins}'") # Simplification
    content = content.replace("'+500 COINS'", "'+500 ${l10n.coins}'")

    content = content.replace("'STATISTICS'", "l10n.statistics")
    content = content.replace("'Played'", "l10n.played")
    content = content.replace("'Won'", "l10n.won")
    content = content.replace("'Win Rate'", "l10n.winRate")
    content = content.replace("'Best Bid'", "l10n.bestBid")

    content = content.replace("'OFFLINE PLAY'", "l10n.offlinePlay")
    content = content.replace("'Play vs Intelligent Bots'", "l10n.playVsIntelligentBots")
    content = content.replace("'Practice your bidding strategies and trick estimation with zero network wait times.'", "l10n.practiceBiddingDesc")

    content = content.replace("'ONLINE PLAY'", "l10n.onlinePlay")
    content = content.replace("'PRIVATE ROOM'", "l10n.privateRoom")
    content = content.replace("'LEADERBOARD'", "l10n.leaderboard")

    content = content.replace("'LIVE'", "l10n.live")
    content = content.replace("'OFFLINE'", "l10n.offline")
    content = content.replace("'STATS'", "l10n.stats")
    
    content = content.replace("'Enable Online Mode in Settings to play online.'", "AppLocalizations.of(context)?.enableOnlineToPlay ?? 'Enable Online Mode in Settings to play online.'")

    # Fix Web Resize Issue and add Accessibility Semantics
    # We will replace the Expanded that contains the "Play vs Intelligent Bots" card
    bot_card_old = """                            Expanded(
                              child: InkWell("""
    bot_card_new = """                            Flexible(
                              child: Semantics(
                                label: l10n.playVsIntelligentBots,
                                hint: l10n.practiceBiddingDesc,
                                button: true,
                                child: InkWell("""
    content = content.replace(bot_card_old, bot_card_new)
    
    # We also need to add Semantics to the other mode cards
    # For _buildModeCard, we'll wrap InkWell in Semantics
    mode_card_old = """    return InkWell("""
    mode_card_new = """    return Semantics(
      label: title,
      button: true,
      child: InkWell("""
    content = content.replace(mode_card_old, mode_card_new)
    
    # For settings button
    settings_old = """                        IconButton(
                          icon: const Icon(Icons.settings"""
    settings_new = """                        Semantics(
                          label: AppLocalizations.of(context)?.settings ?? 'Settings',
                          button: true,
                          child: IconButton(
                            icon: const Icon(Icons.settings"""
    content = content.replace(settings_old, settings_new)
    
    # Close the Semantics for settings button
    settings_close_old = """                          ),
                        ),
                      ],
                    ),"""
    settings_close_new = """                          ),
                          ),
                        ),
                      ],
                    ),"""
    content = content.replace(settings_close_old, settings_close_new)

    with open('lib/screens/home_screen.dart', 'w') as f:
        f.write(content)

if __name__ == '__main__':
    main()
