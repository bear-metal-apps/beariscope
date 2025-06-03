import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// A simpler utility class to get version information across platforms
class AppVersion {
  // Singleton pattern for easy access
  static final AppVersion _instance = AppVersion._internal();

  factory AppVersion() => _instance;

  AppVersion._internal();

  // Store the version info once loaded
  String? _version;
  String? _buildNumber;
  bool _initialized = false;

  /// Initialize version information - call once at app startup
  Future<void> initialize() async {
    if (_initialized) return;

    if (kIsWeb) {
      try {
        final response = await rootBundle.loadString('version.json');
        final data = json.decode(response);
        _version = data['version'];
        _buildNumber = data['build'];
      } catch (e) {
        _version = '0.0.0';
        _buildNumber = '0';
      }
    } else {
      final info = await PackageInfo.fromPlatform();
      _version = info.version;
      _buildNumber = info.buildNumber;
    }

    _initialized = true;
  }

  // Simple getters for version info
  String get version => _version ?? '0.0.0';

  String get buildNumber => _buildNumber ?? '0';

  String get formatted => 'v$version ($buildNumber)';

  // Check if initialized
  bool get isInitialized => _initialized;
}
