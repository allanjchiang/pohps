import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';

/// POHPS Pro offer: free-trial CTA, monthly/annual plan picker with live
/// store pricing, the mandatory auto-renewal/no-refund disclosures, and a
/// required Terms agreement gating the purchase button. Can be embedded
/// inline (inside StatisticsScreen, when access is locked) or pushed as its
/// own route (from a "manage subscription" entry point).
class PaywallScreen extends StatefulWidget {
  final AppState appState;
  final bool embedded;

  const PaywallScreen({
    super.key,
    required this.appState,
    this.embedded = false,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  static const String _privacyPolicyUrl = 'https://logicphile.com/pohps/';

  SubscriptionPlan? _selectedPlan;
  bool _agreedToTerms = false;
  late final TapGestureRecognizer _termsRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _showTermsSheet;
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = _buildContent(context);
    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.pohpsProTitle)),
      body: content,
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;

    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 40 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, l10n),
          const SizedBox(height: 24),
          _buildBenefits(theme, l10n),
          const SizedBox(height: 24),
          if (appState.isSubscribed)
            _buildSubscribedCard(theme, l10n, appState)
          else ...[
            _buildTrialSection(theme, l10n, appState),
            const SizedBox(height: 20),
            _buildPlanSection(theme, l10n, appState),
            const SizedBox(height: 20),
            _buildDisclosure(theme, l10n),
            const SizedBox(height: 16),
            _buildTermsCheckbox(theme, l10n),
            const SizedBox(height: 16),
            _buildSubscribeButton(theme, l10n, appState),
          ],
          const SizedBox(height: 20),
          Center(
            child: TextButton(
              onPressed: appState.purchasePending
                  ? null
                  : () => _handleRestore(context, appState),
              child: Text(l10n.restorePurchases),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: _showTermsSheet,
              child: Text(l10n.viewSubscriptionTerms),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SelectableText(
              _privacyPolicyUrl,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          if (appState.lastPurchaseError != null) ...[
            const SizedBox(height: 16),
            _ErrorBanner(
                theme: theme, message: l10n.purchaseErrorGeneric),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(l10n.pohpsProTitle,
                  style: theme.textTheme.headlineMedium),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.proTagline,
          style: theme.textTheme.bodyLarge
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildBenefits(ThemeData theme, AppLocalizations l10n) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.proBenefitsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...l10n.proBenefits.map((text) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          color: theme.colorScheme.primary, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                          child:
                              Text(text, style: theme.textTheme.bodyLarge)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribedCard(
      ThemeData theme, AppLocalizations l10n, AppState appState) {
    final planName = appState.activePlan == SubscriptionPlan.annual
        ? l10n.annualPlanTitle
        : l10n.monthlyPlanTitle;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified,
                    color: theme.colorScheme.onPrimaryContainer, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.alreadySubscribedTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.alreadySubscribedMessage(planName),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.manageSubscriptionHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer
                    .withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrialSection(
      ThemeData theme, AppLocalizations l10n, AppState appState) {
    if (!appState.hasEverStartedTrial) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.freeTrialTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                l10n.freeTrialSubtitle(AppState.trialDurationDays),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.freeTrialNoCard,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => appState.startFreeTrial(),
                child: Text(l10n.startFreeTrialButton),
              ),
            ],
          ),
        ),
      );
    }
    if (appState.isTrialActive) {
      return _InfoBanner(
        theme: theme,
        icon: Icons.hourglass_top,
        color: theme.colorScheme.primary,
        text: l10n.trialDaysRemainingMessage(appState.trialDaysRemaining),
      );
    }
    return _InfoBanner(
      theme: theme,
      icon: Icons.info_outline,
      color: theme.colorScheme.error,
      text: l10n.trialEndedMessage,
    );
  }

  Widget _buildPlanSection(
      ThemeData theme, AppLocalizations l10n, AppState appState) {
    if (appState.entitlementRestoring) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final monthly = appState.productFor(SubscriptionPlan.monthly);
    final annual = appState.productFor(SubscriptionPlan.annual);
    if (monthly == null && annual == null) {
      return _InfoBanner(
        theme: theme,
        icon: Icons.cloud_off,
        color: theme.colorScheme.onSurfaceVariant,
        text: l10n.subscriptionsUnavailableMessage,
      );
    }
    _selectedPlan ??=
        annual != null ? SubscriptionPlan.annual : SubscriptionPlan.monthly;

    return RadioGroup<SubscriptionPlan>(
      groupValue: _selectedPlan,
      onChanged: (plan) {
        if (plan != null) setState(() => _selectedPlan = plan);
      },
      child: Column(
        children: [
          if (monthly != null)
            Card(
              child: RadioListTile<SubscriptionPlan>(
                value: SubscriptionPlan.monthly,
                title: Text(l10n.monthlyPlanTitle,
                    style: theme.textTheme.titleMedium),
                subtitle: Text(l10n.priceBilledMonthly(monthly.price)),
              ),
            ),
          if (annual != null)
            Card(
              child: RadioListTile<SubscriptionPlan>(
                value: SubscriptionPlan.annual,
                title: Text(l10n.annualPlanTitle,
                    style: theme.textTheme.titleMedium),
                subtitle: Text(l10n.priceBilledAnnually(annual.price)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisclosure(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.renewalDisclosure, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(l10n.noRefundDisclosure, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(ThemeData theme, AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (value) =>
              setState(() => _agreedToTerms = value ?? false),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text.rich(
                TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(text: '${l10n.agreeToTermsPrefix} '),
                    TextSpan(
                      text: l10n.subscriptionTermsLinkText,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _termsRecognizer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscribeButton(
      ThemeData theme, AppLocalizations l10n, AppState appState) {
    final product =
        _selectedPlan == null ? null : appState.productFor(_selectedPlan!);
    final canSubscribe =
        product != null && _agreedToTerms && !appState.purchasePending;
    return FilledButton(
      onPressed: canSubscribe ? () => appState.purchase(product) : null,
      child: appState.purchasePending
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          : Text(l10n.subscribeButton),
    );
  }

  Future<void> _handleRestore(BuildContext context, AppState appState) async {
    final l10n = AppLocalizations.of(context);
    await appState.restorePurchasesManually();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.restoreCompleteMessage,
            style: const TextStyle(fontSize: 16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTermsSheet() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.subscriptionTermsSheetTitle,
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  ...l10n.subscriptionTermsBullets.map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Icon(Icons.circle,
                                  size: 6,
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(text,
                                    style: theme.textTheme.bodyLarge)),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final Color color;
  final String text;

  const _InfoBanner({
    required this.theme,
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final ThemeData theme;
  final String message;

  const _ErrorBanner({required this.theme, required this.message});

  @override
  Widget build(BuildContext context) {
    return _InfoBanner(
      theme: theme,
      icon: Icons.error_outline,
      color: theme.colorScheme.error,
      text: message,
    );
  }
}
