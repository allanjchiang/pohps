import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                'POHPS',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'Protein Tracker for\nLacto-Ovo Vegetarians',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: theme.colorScheme.error, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            'Important Disclaimer',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Please read carefully before using this app:',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _bullet(theme,
                          'This app is NOT a substitute for professional medical or dietary advice. Always consult your doctor or registered dietitian before making changes to your diet.'),
                      _bullet(theme,
                          'The protein values provided are approximate estimates and may vary depending on brands, preparation methods, and serving sizes.'),
                      _bullet(theme,
                          'This app is provided "AS-IS" without any warranties of any kind, either express or implied, including but not limited to fitness for a particular purpose.'),
                      _bullet(theme,
                          'You use this app entirely at your own risk. The developers accept no liability for any health outcomes resulting from use of this app.'),
                      _bullet(theme,
                          'No personal data is collected. All information is stored locally on your device only.'),
                      _bullet(theme,
                          'This is free, open-source software. There are no ads, no paywalls, and no in-app purchases.'),
                      const SizedBox(height: 8),
                      Text(
                        'By tapping "I Understand & Accept" below, you acknowledge that you have read, understood, and agree to these terms.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FilledButton(
                onPressed: () {
                  context.read<AppState>().acceptDisclaimer();
                },
                child: const Text('I Understand & Accept'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showDeclineDialog(context),
                child: const Text('I Do Not Agree'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 8,
                color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }

  void _showDeclineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cannot Continue'),
        content: const Text(
          'You must accept the disclaimer to use this app. '
          'Please close the app if you do not agree with the terms.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
