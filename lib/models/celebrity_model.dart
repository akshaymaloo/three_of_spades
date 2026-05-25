import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Celebrity {
  final String id;
  final String name;
  final String imageUrl;

  const Celebrity({
    required this.id,
    required this.name,
    required this.imageUrl,
  });
}

const List<Celebrity> availableAvatars = [
  Celebrity(id: 'c1', name: 'Cyber Biker', imageUrl: 'assets/images/avatar_cyber_biker.png'),
  Celebrity(id: 'c2', name: 'Neon Queen', imageUrl: 'assets/images/avatar_neon_queen.png'),
  Celebrity(id: 'c3', name: 'Gold King', imageUrl: 'assets/images/avatar_gold_king.png'),
  Celebrity(id: 'c4', name: 'Card Wizard', imageUrl: 'assets/images/avatar_card_wizard.png'),
  Celebrity(id: 'c5', name: 'Retro Hacker', imageUrl: 'assets/images/avatar_retro_hacker.png'),
  Celebrity(id: 'c6', name: 'Synth DJ', imageUrl: 'assets/images/avatar_synth_dj.png'),
];

class AvatarNotifier extends Notifier<Celebrity?> {
  @override
  Celebrity? build() {
    _loadAvatar();
    return null; // temporary null while loading
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('avatar_id');
    if (id == 'custom') {
      final base64Data = prefs.getString('custom_avatar_data');
      if (base64Data != null) {
        state = Celebrity(id: 'custom', name: 'Custom Profile', imageUrl: base64Data);
        return;
      }
    }
    if (id != null) {
      final avatar = availableAvatars.firstWhere(
        (a) => a.id == id,
        orElse: () => availableAvatars.first,
      );
      state = avatar;
    } else {
      state = availableAvatars.first;
    }
  }

  Future<void> setAvatar(Celebrity avatar) async {
    state = avatar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_id', avatar.id);
  }

  Future<void> setCustomAvatar(String base64Data) async {
    final avatar = Celebrity(id: 'custom', name: 'Custom Profile', imageUrl: base64Data);
    state = avatar;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('avatar_id', 'custom');
    await prefs.setString('custom_avatar_data', base64Data);
  }
}

final avatarProvider = NotifierProvider<AvatarNotifier, Celebrity?>(() {
  return AvatarNotifier();
});
