import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostSignInFlowPendingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setPending() {
    state = true;
  }

  void clearPending() {
    state = false;
  }
}

final postSignInFlowPendingProvider =
    NotifierProvider<PostSignInFlowPendingNotifier, bool>(
      PostSignInFlowPendingNotifier.new,
    );
