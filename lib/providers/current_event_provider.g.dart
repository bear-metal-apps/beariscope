// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentEvent)
final currentEventProvider = CurrentEventProvider._();

final class CurrentEventProvider
    extends $NotifierProvider<CurrentEvent, String> {
  CurrentEventProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentEventProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentEventHash();

  @$internal
  @override
  CurrentEvent create() => CurrentEvent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$currentEventHash() => r'048ea4a6002c9b78d1944f1ddce54b4f37aedc06';

abstract class _$CurrentEvent extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
