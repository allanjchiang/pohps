import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

/// The optional-donation content shared by the patch notes popup and the
/// settings page: a short "always free" note, one row per donation amount
/// (priced by the store), and an in-place thank-you or failure message.
class DonationTiers extends StatelessWidget {
  const DonationTiers({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final appState = context.watch<AppState>();

    if (appState.donationThanked) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.donationThanks,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.donationIntro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        for (final product in appState.donationProducts)
          _DonationTier(product: product, appState: appState),
        if (appState.donationFailed)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.donationFailed,
              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

class _DonationTier extends StatelessWidget {
  final ProductDetails product;
  final AppState appState;

  const _DonationTier({required this.product, required this.appState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              appState.donationPending ? null : () => appState.donate(product),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(l10n.donationTierEmoji(product.id),
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.donationTierName(product.id),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (appState.donationPending)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Text(
                    product.price,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: scheme.primary),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Settings-page card offering the same optional donations. Renders nothing
/// when the store has no donation products to show (no store, offline, or
/// products not set up yet).
class DonationCard extends StatefulWidget {
  const DonationCard({super.key});

  @override
  State<DonationCard> createState() => _DonationCardState();
}

class _DonationCardState extends State<DonationCard> {
  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    appState.resetDonationStatus();
    appState.loadDonationProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasProducts =
        context.select<AppState, bool>((s) => s.donationProducts.isNotEmpty);
    if (!hasProducts) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(l10n.supportPohps, style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              const DonationTiers(),
            ],
          ),
        ),
      ),
    );
  }
}
