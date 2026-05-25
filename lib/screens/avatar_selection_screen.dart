import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../models/celebrity_model.dart';
import '../core/theme.dart';
import '../widgets/avatar_image.dart';

class AvatarSelectionScreen extends ConsumerWidget {
  const AvatarSelectionScreen({super.key});

  Future<void> _pickCustomAvatar(BuildContext context, WidgetRef ref) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        await ref.read(avatarProvider.notifier).setCustomAvatar(base64String);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Custom avatar uploaded successfully!'),
              backgroundColor: GameTheme.neonCyan,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildLivePreviewCard(Celebrity currentAvatar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: GameTheme.neonCyan.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GameTheme.neonCyan, width: 3),
              boxShadow: GameTheme.neonGlow(GameTheme.neonCyan, blurRadius: 16),
            ),
            child: ClipOval(
              child: AvatarImage(
                avatarPath: currentAvatar.imageUrl,
                size: 110,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentAvatar.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: GameTheme.goldAccent,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: GameTheme.neonCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GameTheme.neonCyan.withValues(alpha: 0.3), width: 1),
            ),
            child: const Text(
              'ACTIVE PERSONA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: GameTheme.neonCyan,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _pickCustomAvatar(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: GameTheme.goldAccent.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: GameTheme.goldAccent.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: GameTheme.goldAccent),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Upload Custom Picture',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: GameTheme.goldAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonasGrid(WidgetRef ref, Celebrity? currentAvatar) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.8,
      ),
      itemCount: availableAvatars.length,
      itemBuilder: (context, index) {
        final avatar = availableAvatars[index];
        final isSelected = currentAvatar?.id == avatar.id;
        return GestureDetector(
          onTap: () {
            ref.read(avatarProvider.notifier).setAvatar(avatar);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? GameTheme.neonCyan : Colors.white24,
                    width: isSelected ? 3 : 1.5,
                  ),
                  boxShadow: isSelected ? GameTheme.neonGlow(GameTheme.neonCyan) : null,
                ),
                child: ClipOval(
                  child: AvatarImage(
                    avatarPath: avatar.imageUrl,
                    size: 76,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                avatar.name,
                style: TextStyle(
                  color: isSelected ? GameTheme.neonCyan : GameTheme.textWhite,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAvatar = ref.watch(avatarProvider);
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: GameTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Choose Avatar', style: TextStyle(color: GameTheme.textWhite, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: GameTheme.neonCyan),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: GameTheme.backgroundGradient,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Live Preview & Upload Custom Button
                    Expanded(
                      flex: 4,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            if (currentAvatar != null) _buildLivePreviewCard(currentAvatar),
                            const SizedBox(height: 16),
                            _buildUploadButton(context, ref),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Default Personas list
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Default Personas',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: GameTheme.textWhite,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: _buildPersonasGrid(ref, currentAvatar),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    // Live Preview Card
                    if (currentAvatar != null) _buildLivePreviewCard(currentAvatar),
                    const SizedBox(height: 20),
                    // Custom Upload Action Card
                    _buildUploadButton(context, ref),
                    const SizedBox(height: 24),
                    // Grid header
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Default Personas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: GameTheme.textWhite,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Available Personas Grid
                    Expanded(
                      child: _buildPersonasGrid(ref, currentAvatar),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
