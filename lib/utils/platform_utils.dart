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

  static bool useDesktopUI(BuildContext context) {
    return isDesktop() &&
        MediaQuery.sizeOf(context).width >= 600 &&
        MediaQuery.sizeOf(context).height >= 510;
  }
}
