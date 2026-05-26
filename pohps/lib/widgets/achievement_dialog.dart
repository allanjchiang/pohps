import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

class AchievementDialog extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback onDismiss;

  const AchievementDialog({
    super.key,
    required this.achievement,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.achievementUnlocked,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.achievementTitle(achievement.type.name, achievement.title),
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.achievementDesc(
                  achievement.type.name, achievement.description),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: onDismiss,
              child: Text(l10n.wonderful),
            ),
          ],
        ),
      ),
    );
  }
}
