// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pits_scouting_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pitsScouted)
final pitsScoutedProvider = PitsScoutedProvider._();

final class PitsScoutedProvider
    extends $FunctionalProvider<Set<int>, Set<int>, Set<int>>
    with $Provider<Set<int>> {
  PitsScoutedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pitsScoutedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pitsScoutedHash();

  @$internal
  @override
  $ProviderElement<Set<int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<int> create(Ref ref) {
    return pitsScouted(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<int>>(value),
    );
  }
}

String _$pitsScoutedHash() => r'10887ec4bbe4a8e130c330c634d768deeaa143db';

@ProviderFor(pitsMap)
final pitsMapProvider = PitsMapProvider._();

final class PitsMapProvider
    extends
        $FunctionalProvider<
          AsyncValue<PitsMapData>,
          PitsMapData,
          FutureOr<PitsMapData>
        >
    with $FutureModifier<PitsMapData>, $FutureProvider<PitsMapData> {
  PitsMapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pitsMapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pitsMapHash();

  @$internal
  @override
  $FutureProviderElement<PitsMapData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PitsMapData> create(Ref ref) {
    return pitsMap(ref);
  }
}

String _$pitsMapHash() => r'c62baafd46bfe18f0e8505e5e18b6e96f3e06706';
