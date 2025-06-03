// Empty implementations for web, because getting these isn't supported there

import 'package:flutter/material.dart';

class PlatformUtils {
  static bool isMobile() => false;

  static bool isDesktop() => false;

  static bool isWeb() => true;

  static bool useDesktopUI(dynamic context) {
    // Use desktop UI on web if the screen is wide and tall enough
    try {
      if (context != null && context is BuildContext) {
        return MediaQuery.of(context).size.width >= 600 &&
            MediaQuery.of(context).size.height >= 400;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
