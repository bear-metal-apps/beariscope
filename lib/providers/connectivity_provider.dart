import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Streams `true` when the device has an internet connection, `false` when
/// offline.  Starts with an immediate check so the UI has a value on first
/// build.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final checker = InternetConnection.createInstance();

  // Emit the current status immediately before waiting for changes.
  yield await checker.hasInternetAccess;

  await for (final status in checker.onStatusChange) {
    yield status == InternetStatus.connected;
  }
});
