import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/multiplayer_state.dart';
import '../providers/multiplayer_notifier.dart';
import '../l10n/app_localizations.dart';

class PrivateRoomScreen extends ConsumerStatefulWidget {
  const PrivateRoomScreen({super.key});

  @override
  ConsumerState<PrivateRoomScreen> createState() => _PrivateRoomScreenState();
}

class _PrivateRoomScreenState extends ConsumerState<PrivateRoomScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCreating = true; // true = create path, false = join path
  bool _joined = false;    // for join path, true when joined room lobby

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCreateRoom() {
    setState(() {
      _isCreating = true;
      _joined = true;
    });
    ref.read(multiplayerProvider.notifier).createPrivateRoom();
  }

  void _onJoinRoomSubmit() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.invalidRoomCode ?? 'Please enter a valid room code.')),
      );
      return;
    }
    setState(() {
      _joined = true;
    });
    ref.read(multiplayerProvider.notifier).joinPrivateRoom(code);
  }

  @override
  Widget build(BuildContext context) {
    final mState = ref.watch(multiplayerProvider);

    // Pop the screen automatically if state has transitioned to playing
    if (mState.status == MultiplayerStatus.playing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: GameTheme.textWhite),
                      onPressed: () {
                        ref.read(multiplayerProvider.notifier).cancelMatchmaking();
                        Navigator.pop(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _joined 
                          ? (AppLocalizations.of(context)?.privateLobby ?? 'PRIVATE LOBBY') 
                          : (AppLocalizations.of(context)?.privateRoom ?? 'PRIVATE ROOM'),
                      style: const TextStyle(
                        color: GameTheme.textWhite,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 550),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: GameTheme.glassDecoration(opacity: 0.04, borderOpacity: 0.1),
                      child: SingleChildScrollView(
                        child: !_joined 
                            ? _buildSelectionLayout() 
                            : _buildLobbyLayout(mState),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionLayout() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isCreating = true),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _isCreating ? GameTheme.neonCyan : Colors.white10,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _isCreating ? GameTheme.neonCyan.withValues(alpha: 0.05) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.createRoom ?? 'CREATE ROOM',
                      style: TextStyle(
                        color: _isCreating ? GameTheme.neonCyan : GameTheme.textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => setState(() => _isCreating = false),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: !_isCreating ? GameTheme.neonCyan : Colors.white10,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: !_isCreating ? GameTheme.neonCyan.withValues(alpha: 0.05) : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.joinRoom ?? 'JOIN ROOM',
                      style: TextStyle(
                        color: !_isCreating ? GameTheme.neonCyan : GameTheme.textGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        if (_isCreating) ...[
          Text(
            AppLocalizations.of(context)?.createLobbyDesc ?? 'Create a private lobby code. You can invite your friends to join this lobby or fill up seats with bots.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameTheme.textGrey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 32),
          InkWell(
            onTap: _onCreateRoom,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: GameTheme.neonCyanGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: GameTheme.neonGlow(GameTheme.neonCyan),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)?.generateRoom ?? 'GENERATE ROOM',
                  style: const TextStyle(color: GameTheme.darkBackground, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ] else ...[
          Text(
            AppLocalizations.of(context)?.enterRoomCodeDesc ?? 'Enter the 6-character room code to join an active private lobby.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: GameTheme.textGrey, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              LengthLimitingTextInputFormatter(9),
            ],
            style: const TextStyle(
              color: GameTheme.neonCyan,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 6,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'TS-XXXXXX',
              hintStyle: TextStyle(
                color: GameTheme.textGrey.withValues(alpha: 0.3),
                fontSize: 22,
                fontWeight: FontWeight.normal,
                letterSpacing: 4,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: GameTheme.neonCyan.withValues(alpha: 0.3), width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: GameTheme.neonCyan, width: 2.0),
                borderRadius: BorderRadius.circular(12),
              ),
              fillColor: Colors.white.withValues(alpha: 0.01),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _onJoinRoomSubmit,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: GameTheme.neonCyanGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: GameTheme.neonGlow(GameTheme.neonCyan),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)?.joinLobby ?? 'JOIN LOBBY',
                  style: const TextStyle(color: GameTheme.darkBackground, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.5),
                ),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildLobbyLayout(MultiplayerState mState) {
    final codeDisplay = mState.roomCode.isNotEmpty ? mState.roomCode : 'TS-******';
    final isFull = mState.lobbyPlayers.length >= 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Room Code Badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: GameTheme.neonCyan.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.4)),
              boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)?.roomCodeLabel ?? 'ROOM CODE: ',
                  style: const TextStyle(color: GameTheme.textGrey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  codeDisplay,
                  style: const TextStyle(color: GameTheme.neonCyan, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

        // List of players currently seated
        Text(
          AppLocalizations.of(context)?.seatedPlayers ?? 'SEATED PLAYERS (Max 4)',
          style: const TextStyle(color: GameTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(4, (index) {
            final hasPlayer = mState.lobbyPlayers.length > index;
            final name = hasPlayer ? mState.lobbyPlayers[index] : (AppLocalizations.of(context)?.emptySeat ?? 'Empty Seat');
            final isUser = index == 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.01),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasPlayer 
                      ? (isUser ? GameTheme.neonCyan : GameTheme.neonGreen).withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasPlayer ? Icons.person_rounded : Icons.add_circle_outline_rounded,
                    color: hasPlayer 
                        ? (isUser ? GameTheme.neonCyan : GameTheme.neonGreen)
                        : GameTheme.textGrey.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    name,
                    style: TextStyle(
                      color: hasPlayer ? GameTheme.textWhite : GameTheme.textGrey.withValues(alpha: 0.3),
                      fontWeight: hasPlayer ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (hasPlayer) ...[
                    Text(
                      isUser 
                          ? (AppLocalizations.of(context)?.host ?? 'HOST') 
                          : (AppLocalizations.of(context)?.ready ?? 'READY'),
                      style: TextStyle(
                        color: isUser ? GameTheme.neonCyan : GameTheme.neonGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ] else ...[
                    Text(
                      AppLocalizations.of(context)?.waiting ?? 'WAITING...',
                      style: TextStyle(
                        color: GameTheme.textGrey.withValues(alpha: 0.2),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 32),

        // Action buttons
        Row(
          children: [
            if (_isCreating && !isFull) ...[
              Expanded(
                child: TextButton(
                  onPressed: () => ref.read(multiplayerProvider.notifier).fillWithBots(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: GameTheme.neonCyan, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)?.addBots ?? 'ADD BOTS',
                    style: const TextStyle(color: GameTheme.neonCyan, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: InkWell(
                onTap: isFull 
                    ? () => ref.read(multiplayerProvider.notifier).startGameDirectly()
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: Opacity(
                  opacity: isFull ? 1.0 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: isFull ? GameTheme.neonCyanGradient : null,
                      color: isFull ? null : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isFull ? GameTheme.neonGlow(GameTheme.neonCyan) : null,
                    ),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)?.startMatch ?? 'START MATCH',
                        style: const TextStyle(
                          color: GameTheme.darkBackground,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
