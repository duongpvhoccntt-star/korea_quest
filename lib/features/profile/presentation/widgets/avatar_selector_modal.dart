import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:korea_quest/design_system/colors/app_colors.dart';
import 'package:korea_quest/design_system/components/app_buttons.dart';
import 'package:korea_quest/design_system/components/progress_components.dart';
import 'package:korea_quest/design_system/radius/app_radius.dart';
import 'package:korea_quest/design_system/spacing/app_spacing.dart';
import 'package:korea_quest/l10n/app_strings.dart';

/// Result of avatar selection — either a preset key or raw bytes from device.
typedef AvatarSelection = ({String? preset, Uint8List? bytes});

class AvatarSelectorModal extends StatefulWidget {
  const AvatarSelectorModal({super.key, this.currentPreset, this.currentBytes});

  final String? currentPreset;
  final Uint8List? currentBytes;

  static Future<AvatarSelection?> show(
    BuildContext context, {
    String? currentPreset,
    Uint8List? currentBytes,
  }) => showModalBottomSheet<AvatarSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AvatarSelectorModal(
      currentPreset: currentPreset,
      currentBytes: currentBytes,
    ),
  );

  @override
  State<AvatarSelectorModal> createState() => _AvatarSelectorModalState();
}

class _AvatarSelectorModalState extends State<AvatarSelectorModal> {
  String? _selectedPreset;
  Uint8List? _selectedBytes;

  @override
  void initState() {
    super.initState();
    _selectedPreset = widget.currentPreset;
    _selectedBytes = widget.currentBytes;
  }

  Future<void> _pickFromDevice() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.first.bytes;
    if (bytes == null) return;
    setState(() {
      _selectedBytes = bytes;
      _selectedPreset = null;
    });
  }

  void _selectPreset(String key) {
    setState(() {
      _selectedPreset = key;
      _selectedBytes = null;
    });
  }

  static const _presets = <String, ({String emoji, String label})>{
    'hanbok': (emoji: '🎎', label: 'Hanbok Explorer'),
    'seoul': (emoji: '🗼', label: 'Seoul Traveler'),
    'haechi': (emoji: '🦁', label: 'Haechi Guardian'),
    'scholar': (emoji: '📜', label: 'Joseon Scholar'),
    'foodie': (emoji: '🍲', label: 'K-Foodie'),
    'kpop': (emoji: '🎵', label: 'K-Pop Fan'),
  };

  @override
  Widget build(BuildContext context) {
    final preview = UserAvatar(
      displayName: '?',
      radius: 48,
      avatarPreset: _selectedPreset,
      avatarBytes: _selectedBytes,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSoft,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title + preview
            Row(
              children: [
                preview,
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appStrings(context).changeAvatar,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        appStrings(context).avatarDescription,
                        style: const TextStyle(color: AppColors.stitchMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // From device button
            OutlinedButton.icon(
              onPressed: _pickFromDevice,
              icon: const Icon(Icons.upload_file_rounded),
              label: Text(appStrings(context).uploadFromDevice),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Preset grid
            Text(
              appStrings(context).chooseAvatar,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.stitchMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 120,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
              ),
              itemCount: _presets.length,
              itemBuilder: (context, i) {
                final key = _presets.keys.elementAt(i);
                final preset = _presets[key]!;
                final isSelected = _selectedPreset == key;
                return GestureDetector(
                  onTap: () => _selectPreset(key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.koreanRed
                            : AppColors.borderSoft,
                        width: isSelected ? 2.5 : 1,
                      ),
                      color: isSelected
                          ? AppColors.palePink.withValues(alpha: 0.3)
                          : Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          preset.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          preset.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.koreanRed
                                : AppColors.stitchText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: appStrings(context).cancel,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: appStrings(context).confirm,
                    icon: Icons.check_rounded,
                    onPressed: () => Navigator.pop<AvatarSelection>(context, (
                      preset: _selectedPreset,
                      bytes: _selectedBytes,
                    )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
