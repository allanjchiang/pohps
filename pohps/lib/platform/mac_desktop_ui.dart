import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// True when running the macOS desktop embedder.
bool get isMacOSDesktop =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;

/// Enables click-and-drag scrolling on scrollables (ListView, etc.) with a mouse.
class MacDesktopScrollBehavior extends MaterialScrollBehavior {
  const MacDesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}

/// macOS desktop wrapper — pass-through; pan shell removed (broke viewport layout).
Widget wrapMacDesktopShell(Widget child) => child;
