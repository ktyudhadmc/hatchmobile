import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/dialog_helper.dart';

/// Wires an [AsyncValue] provider to the standard loading-dialog /
/// success-callback / error-toast UX so pages don't repeat that
/// boilerplate around every async action (login, submit, sync, ...).
mixin AsyncStateHandlerMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final List<ProviderSubscription> _subscriptions = [];

  void listenAsync<S>({
    required ProviderListenable<AsyncValue<S>> provider,
    required void Function(S data) onData,
    void Function(Object err, StackTrace stack)? onError,
    String? loadingMessage,
  }) {
    final sub = ref.listenManual<AsyncValue<S>>(provider, (previous, next) {
      next.when(
        loading: () => DialogHelper.showLoading(context, message: loadingMessage),
        data: (state) {
          DialogHelper.hideLoading(context);
          onData(state);
        },
        error: (err, stack) {
          DialogHelper.hideLoading(context);
          if (onError != null) {
            onError(err, stack);
          } else {
            ToastHelper.error(err.toString());
          }
        },
      );
    }, fireImmediately: false);

    _subscriptions.add(sub);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.close();
    }
    super.dispose();
  }
}
