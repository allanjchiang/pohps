import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'l10n/app_localizations.dart';
import 'theme.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/goal_setup_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.init();
  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const PohpsApp(),
    ),
  );
}

class PohpsApp extends StatelessWidget {
  const PohpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return MaterialApp(
      title: 'POHPS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appState.themeMode,
      locale: appState.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: _buildHome(appState),
    );
  }

  Widget _buildHome(AppState appState) {
    if (!appState.disclaimerAccepted) return const DisclaimerScreen();
    if (appState.dailyGoal <= 0) return const GoalSetupScreen();
    return const DashboardScreen();
  }
}
