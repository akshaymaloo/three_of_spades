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

// Hardcoded list of celebrity avatars as in the Android app (or placeholder images)
const List<Celebrity> availableAvatars = [
  Celebrity(id: 'c1', name: 'Shahrukh', imageUrl: 'https://i.pinimg.com/236x/8f/c9/2b/8fc92b6a55c2f8211db4c1a85b9b9a67.jpg'),
  Celebrity(id: 'c2', name: 'Salman', imageUrl: 'https://i.pinimg.com/236x/2c/3e/2a/2c3e2a0f8b1c4b7f8c12a3b1a2b9a11d.jpg'),
  Celebrity(id: 'c3', name: 'Aamir', imageUrl: 'https://i.pinimg.com/236x/7d/5c/b8/7d5cb8d2c9f5f0b5c1c8c8b1a8f9a911.jpg'),
  Celebrity(id: 'c4', name: 'Amitabh', imageUrl: 'https://i.pinimg.com/236x/5f/1d/9b/5f1d9b9a1c8f1e9c8a1b9a911d.jpg'),
  Celebrity(id: 'c5', name: 'Deepika', imageUrl: 'https://i.pinimg.com/236x/1a/2b/3c/1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d.jpg'),
  Celebrity(id: 'c6', name: 'Priyanka', imageUrl: 'https://i.pinimg.com/236x/9a/8b/7c/9a8b7c6d5e4f3a2b1c0d9e8f7a6b5c4d.jpg'),
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
}

final avatarProvider = NotifierProvider<AvatarNotifier, Celebrity?>(() {
  return AvatarNotifier();
});
