import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers/stats_provider.dart';
import '../l10n/app_localizations.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _finishTutorial() async {
    await ref.read(statsProvider.notifier).completeTutorial();
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 720, maxHeight: 380),
                padding: const EdgeInsets.all(24),
                decoration: GameTheme.glassDecoration(
                  opacity: 0.05,
                  borderOpacity: 0.12,
                  borderColor: GameTheme.neonCyan,
                  radius: 24,
                ),
                child: Column(
                  children: [
                    // Header / Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '♠',
                              style: TextStyle(color: GameTheme.neonPink, fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)?.howToPlay ?? 'HOW TO PLAY',
                              style: const TextStyle(
                                color: GameTheme.textWhite,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        // Dots Indicator
                        Row(
                          children: List.generate(_totalPages, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: isActive ? 20 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isActive ? GameTheme.neonCyan : Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: isActive ? GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 4) : null,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    
                    // Page Content
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: _onPageChanged,
                        children: [
                          _buildWelcomePage(),
                          _buildObjectivePage(),
                          _buildCardValuesPage(),
                          _buildFlowPage(),
                          _buildTipsPage(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    // Navigation Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip Button
                        TextButton(
                          onPressed: _finishTutorial,
                          child: Text(
                            AppLocalizations.of(context)?.skip ?? 'SKIP',
                            style: const TextStyle(
                              color: GameTheme.textGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        
                        // Next / Start Button
                        InkWell(
                          onTap: () {
                            if (_currentPage < _totalPages - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              _finishTutorial();
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: _currentPage == _totalPages - 1
                                  ? GameTheme.neonPinkGradient
                                  : GameTheme.neonCyanGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: GameTheme.neonGlow(
                                _currentPage == _totalPages - 1 ? GameTheme.neonPink : GameTheme.neonCyan,
                                blurRadius: 6,
                              ),
                            ),
                            child: Text(
                              _currentPage == _totalPages - 1 
                                  ? (AppLocalizations.of(context)?.letsPlay ?? 'LET\'S PLAY!') 
                                  : (AppLocalizations.of(context)?.next ?? 'NEXT'),
                              style: const TextStyle(
                                color: GameTheme.darkBackground,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.welcomeTitle ?? 'Welcome to Three of Spades',
                style: const TextStyle(
                  color: GameTheme.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)?.welcomeDesc ?? 'Also known as Kaali Ki Teeggi, this is a strategic trick-taking card game popular in South Asia. In this modernized cyberpunk version, you play against smart bots or online players in a battle of bidding, declarations, and tactical play.',
                style: const TextStyle(color: GameTheme.textGrey, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: Center(
            child: Icon(
              Icons.style_rounded,
              color: GameTheme.neonCyan,
              size: 80,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildObjectivePage() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.objectiveTitle ?? 'The Objective & Bidding',
                style: const TextStyle(
                  color: GameTheme.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context)?.objectiveDesc ?? 'Players bid points (from 175 to 350) based on their hand strength. The highest bidder wins the bid and tries to make that many points. Bids can only be placed or passed, and bidding progresses in increments of 5.',
                style: const TextStyle(color: GameTheme.textGrey, fontSize: 13, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: GameTheme.glassDecoration(opacity: 0.05, borderOpacity: 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gavel_rounded, color: GameTheme.neonPink, size: 36),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.minBidLabel ?? 'Min Bid: 175',
                  style: const TextStyle(color: GameTheme.neonPink, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  AppLocalizations.of(context)?.maxBidLabel ?? 'Max Bid: 350',
                  style: const TextStyle(color: GameTheme.textGrey, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardValuesPage() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.scoringTitle ?? 'Scoring & Point Cards',
                style: const TextStyle(
                  color: GameTheme.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppLocalizations.of(context)?.scoringDesc ?? 'Unlike standard card games, only specific cards carry points. Winning tricks containing these cards earns points:',
                style: const TextStyle(color: GameTheme.textGrey, fontSize: 12, height: 1.3),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPointBadge('3 ♠', '30 Pts', GameTheme.neonPink),
                  _buildPointBadge('A (All)', '20 Pts', GameTheme.goldAccent),
                  _buildPointBadge('10 (All)', '10 Pts', GameTheme.neonCyan),
                  _buildPointBadge('5 (All)', '5 Pts', GameTheme.neonGreen),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: GameTheme.glassDecoration(opacity: 0.05, borderOpacity: 0.1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)?.totalPointsLabel ?? 'Total Points: 350',
                  style: const TextStyle(color: GameTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)?.scoringTeamDesc ?? 'The bidder + partner team must win tricks containing point cards equal to or greater than their bid to win!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, height: 1.3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointBadge(String label, String points, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 2),
          Text(points, style: const TextStyle(color: GameTheme.textWhite, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFlowPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.gameplayFlowTitle ?? 'Gameplay Flow',
          style: const TextStyle(
            color: GameTheme.neonCyan,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFlowStep('1', AppLocalizations.of(context)?.flowStep1Title ?? 'Bidding', AppLocalizations.of(context)?.flowStep1Desc ?? 'Players bid points'),
            _buildFlowStep('2', AppLocalizations.of(context)?.flowStep2Title ?? 'Declaration', AppLocalizations.of(context)?.flowStep2Desc ?? 'Bidder picks Trump & Partner card'),
            _buildFlowStep('3', AppLocalizations.of(context)?.flowStep3Title ?? 'Trick Play', AppLocalizations.of(context)?.flowStep3Desc ?? 'Follow suits to win tricks'),
            _buildFlowStep('4', AppLocalizations.of(context)?.flowStep4Title ?? 'Scoring', AppLocalizations.of(context)?.flowStep4Desc ?? 'Sum points from tricks won'),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowStep(String num, String title, String desc) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: GameTheme.glassDecoration(opacity: 0.03, borderOpacity: 0.08),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: GameTheme.neonCyan,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  num,
                  style: const TextStyle(color: GameTheme.darkBackground, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameTheme.textWhite, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsPage() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)?.tipsTitle ?? 'Tips & Rules',
                style: const TextStyle(
                  color: GameTheme.neonCyan,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              BulletPoint(AppLocalizations.of(context)?.tip1 ?? 'You MUST follow the suit led if you have it in your hand.'),
              const SizedBox(height: 4),
              BulletPoint(AppLocalizations.of(context)?.tip2 ?? 'If you don\'t have the led suit, you can play any card, including a Trump to win the trick.'),
              const SizedBox(height: 4),
              BulletPoint(AppLocalizations.of(context)?.tip3 ?? 'The partner is secret! Only when the declared Partner card is played is the partner\'s identity revealed.'),
            ],
          ),
        ),
        const SizedBox(width: 24),
        const Expanded(
          child: Center(
            child: Icon(
              Icons.lightbulb_outline_rounded,
              color: GameTheme.goldAccent,
              size: 80,
            ),
          ),
        ),
      ],
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4.0, right: 8.0),
          child: Icon(Icons.circle, size: 6, color: GameTheme.neonPink),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: GameTheme.textGrey, fontSize: 12, height: 1.3),
          ),
        ),
      ],
    );
  }
}
