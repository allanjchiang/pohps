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

/// Wraps the app so the whole UI can be click-dragged in any direction on macOS.
class MacDesktopPanShell extends StatelessWidget {
  final Widget child;

  const MacDesktopPanShell({super.key, required this.child});

  static const _panMargin = 160.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return InteractiveViewer(
      scaleEnabled: false,
      panEnabled: true,
      constrained: false,
      boundaryMargin: const EdgeInsets.all(_panMargin),
      minScale: 1.0,
      maxScale: 1.0,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      ),
    );
  }
}

/// Applies macOS desktop pan + mouse-drag scroll when [child] is the app root.
Widget wrapMacDesktopShell(Widget child) {
  if (!isMacOSDesktop) return child;
  return MacDesktopPanShell(child: child);
}
