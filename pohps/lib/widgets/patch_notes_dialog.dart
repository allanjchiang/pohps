import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../data/patch_notes.dart';
import '../l10n/app_localizations.dart';
import 'donation_tiers.dart';

/// "What's New" popup shown once after an app update. Important updates also
/// offer an optional donation button at the bottom left.
class PatchNotesDialog extends StatefulWidget {
  final PatchNote note;

  const PatchNotesDialog({super.key, required this.note});

  @override
  State<PatchNotesDialog> createState() => _PatchNotesDialogState();
}

class _PatchNotesDialogState extends State<PatchNotesDialog> {
  final _scrollController = ScrollController();
  bool _showTiers = false;

  @override
  void initState() {
    super.initState();
    if (widget.note.important) {
      final appState = context.read<AppState>();
      appState.resetDonationStatus();
      appState.loadDonationProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleTiers() {
    setState(() => _showTiers = !_showTiers);
    if (_showTiers) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();
    final canDonate =
        widget.note.important && appState.donationProducts.isNotEmpty;

    return Dialog(
      clipBehavior: Clip.antiAlias,
      backgroundColor: scheme.surface,
      surfaceTintColor: scheme.surfaceTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, l10n),
            Flexible(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in widget.note.items)
                      _buildItem(theme, l10n, item),
                    if (canDonate)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        alignment: Alignment.topCenter,
                        child: _showTiers
                            ? _buildDonationPanel(theme)
                            : const SizedBox(width: double.infinity),
                      ),
                  ],
                ),
              ),
            ),
            _buildFooter(l10n, canDonate),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scheme.primaryContainer, scheme.surface],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Text('🌿', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.patchNotesTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                l10n.patchNotesVersion(widget.note.version),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Positioned(
            top: -12,
            right: -16,
            child: IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.closeLabel,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      ThemeData theme, AppLocalizations l10n, PatchNoteItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.localized(item.en, item.zhTW, item.zhCN),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.35),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationPanel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const DonationTiers(),
    );
  }

  Widget _buildFooter(AppLocalizations l10n, bool canDonate) {
    const buttonSize = Size(0, 52);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Row(
        children: [
          if (canDonate) ...[
            Expanded(
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(minimumSize: buttonSize),
                onPressed: _toggleTiers,
                icon: const Icon(Icons.favorite_border),
                label: Text(l10n.donateButton),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: buttonSize),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.gotIt),
            ),
          ),
        ],
      ),
    );
  }
}
