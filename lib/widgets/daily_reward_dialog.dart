import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/daily_reward_provider.dart';
import '../l10n/app_localizations.dart';

class DailyRewardDialog extends ConsumerWidget {
  final Function(int amount) onClaim;

  const DailyRewardDialog({
    super.key,
    required this.onClaim,
  });

  /// Convenience method to show the dialog.
  static void show(BuildContext context, {required Function(int) onClaim}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DailyRewardDialog(onClaim: onClaim),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardState = ref.watch(dailyRewardProvider);
    final notifier = ref.read(dailyRewardProvider.notifier);

    final currentDay = rewardState.consecutiveDays; // 0-indexed days claimed so far
    final todayClaimed = rewardState.todayClaimed;

    // The next day to claim is currentDay + 1 (1-indexed), but if already
    // claimed today the "current" day is currentDay itself.
    final displayDay = todayClaimed ? currentDay : currentDay + 1;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(context).height - 48,
          ),
          decoration: BoxDecoration(
            color: GameTheme.darkBackground.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: GameTheme.goldAccent.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: GameTheme.neonGlow(GameTheme.goldAccent, blurRadius: 15),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              // ── Header ──
              _buildHeader(context),

              // ── Reward Grid ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: List.generate(7, (index) {
                    final dayNumber = index + 1; // 1-indexed
                    return _buildDayCard(
                      context: context,
                      dayNumber: dayNumber,
                      amount: notifier.rewardForDay(dayNumber),
                      isCurrent: dayNumber == displayDay,
                      isClaimed: dayNumber < displayDay ||
                          (dayNumber == displayDay && todayClaimed),
                      isFuture: dayNumber > displayDay,
                    );
                  }),
                ),
              ),

              // ── Claim Button ──
              _buildClaimButton(context, ref, notifier, todayClaimed, displayDay),
            ],
          ),
        ),
      ),
    ),
  );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '🎁 ${AppLocalizations.of(context)?.dailyReward.toUpperCase() ?? 'DAILY REWARD'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: GameTheme.goldAccent,
              letterSpacing: 1.5,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: GameTheme.textGrey, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── Day Card ────────────────────────────────────────────────────────────

  Widget _buildDayCard({
    required BuildContext context,
    required int dayNumber,
    required int amount,
    required bool isCurrent,
    required bool isClaimed,
    required bool isFuture,
  }) {
    final Color borderColor;
    final Color bgColor;
    final double textOpacity;

    if (isClaimed) {
      borderColor = Colors.green.withValues(alpha: 0.4);
      bgColor = Colors.green.withValues(alpha: 0.08);
      textOpacity = 0.5;
    } else if (isCurrent) {
      borderColor = GameTheme.goldAccent.withValues(alpha: 0.7);
      bgColor = GameTheme.goldAccent.withValues(alpha: 0.1);
      textOpacity = 1.0;
    } else {
      // future
      borderColor = Colors.white.withValues(alpha: 0.08);
      bgColor = Colors.white.withValues(alpha: 0.03);
      textOpacity = 0.35;
    }

    return SizedBox(
      width: 80,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isCurrent ? 2.0 : 1.0),
          boxShadow: isCurrent
              ? [
                  BoxShadow(
                    color: GameTheme.goldAccent.withValues(alpha: 0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.dayNumber(dayNumber) ?? 'Day $dayNumber',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: GameTheme.textWhite.withValues(alpha: textOpacity),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '🪙',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white.withValues(alpha: textOpacity),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$amount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: GameTheme.goldAccent.withValues(alpha: textOpacity),
                  ),
                ),
              ],
            ),
            if (isClaimed)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.withValues(alpha: 0.7),
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Claim Button ────────────────────────────────────────────────────────

  Widget _buildClaimButton(
    BuildContext context,
    WidgetRef ref,
    DailyRewardNotifier notifier,
    bool todayClaimed,
    int displayDay,
  ) {
    final rewardAmount = notifier.rewardForDay(displayDay);
    final enabled = !todayClaimed;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: enabled ? GameTheme.neonCyanGradient : null,
            color: enabled ? null : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
          ),
          child: MaterialButton(
            onPressed: enabled
                ? () async {
                    final amount = await notifier.claimReward();
                    if (amount > 0) {
                      onClaim(amount);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              todayClaimed
                  ? (AppLocalizations.of(context)?.alreadyClaimed ?? 'Already Claimed ✓')
                  : (AppLocalizations.of(context)?.claimCoins(rewardAmount) ?? 'Claim $rewardAmount Coins!'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: enabled
                    ? GameTheme.textWhite
                    : GameTheme.textGrey,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
