import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PlatformUtils {
  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isDesktop() {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  }

  static bool isWeb() {
    return kIsWeb;
  }

  static bool isTablet(BuildContext context) {
    if (isMobile()) {
      return MediaQuery.of(context).size.shortestSide >= 600;
    }
    return false;
  }
}
