import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'current_event_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentEvent extends _$CurrentEvent {
  static const _storageKey = 'current_event_key';
  static const _defaultEventKey = '2026wabon';

	@override
  String build() {
    _loadEventKey();
    return _defaultEventKey;
  }

  Future<void> _loadEventKey() async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_storageKey);
    if (savedKey != null && savedKey.isNotEmpty) {
      state = savedKey;
      return;
    }

    await _setAndPersist(_defaultEventKey, prefs);
  }

  Future<void> setEventKey(String? eventKey) async {
    final trimmed = eventKey?.trim();
    final prefs = await SharedPreferences.getInstance();

    final value =
        trimmed == null || trimmed.isEmpty ? _defaultEventKey : trimmed;
    await _setAndPersist(value, prefs);
  }

  Future<void> _setAndPersist(
    String value,
    SharedPreferences prefs,
  ) async {
    state = value;
    await prefs.setString(_storageKey, value);
  }
}
