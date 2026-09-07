import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_service.dart';
import 'sheets/no_internet_sheet.dart';

/// Wraps the whole app (via `MaterialApp.router`'s `builder`) and watches
/// [connectivityStatusProvider]: opens [NoInternetSheet] the moment the
/// connection drops and pops it the moment it's back, regardless of which
/// page is currently on screen.
class ConnectivityGate extends ConsumerStatefulWidget {
  const ConnectivityGate({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  ConsumerState<ConnectivityGate> createState() => _ConnectivityGateState();
}

class _ConnectivityGateState extends ConsumerState<ConnectivityGate> {
  bool _isSheetOpen = false;

  void _handleStatus(bool isConnected) {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;

    if (!isConnected && !_isSheetOpen) {
      _isSheetOpen = true;
      NoInternetSheet.show(context).whenComplete(() {
        _isSheetOpen = false;
      });
    } else if (isConnected && _isSheetOpen) {
      final navigator = widget.navigatorKey.currentState;
      if (navigator != null && navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(connectivityStatusProvider, (_, next) {
      final isConnected = next.valueOrNull;
      if (isConnected == null) return;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _handleStatus(isConnected),
      );
    });

    return widget.child;
  }
}
