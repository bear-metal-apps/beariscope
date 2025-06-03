// Empty implementations for web, because getting these isn't supported there

import 'package:flutter/material.dart';

class PlatformUtils {
  static bool isMobile() => false;

  static bool isDesktop() => false;

  static bool isWeb() => true;

  static bool useDesktopUI(dynamic context) {
    // Use desktop UI on web if the screen is wide enough
    try {
      final width =
          context != null && context is BuildContext
              ? MediaQuery.of(context).size.width
              : 0;
      return width >= 600;
    } catch (_) {
      return false;
    }
  }
}
