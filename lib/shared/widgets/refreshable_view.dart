import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Pull-to-refresh wrapper with consistent app styling, so every page wires
/// it up the same way instead of configuring [RefreshIndicator] by hand.
///
/// [child] must be (or contain) a [Scrollable] — that's what actually
/// detects the pull gesture. For loading/empty/error states with nothing to
/// naturally scroll, wrap them in a [ListView] with
/// [AlwaysScrollableScrollPhysics] rather than a bare [Center], otherwise
/// the pull gesture has nothing to attach to and silently does nothing.
class RefreshableView extends StatelessWidget {
  const RefreshableView({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppTheme.primaryColor,
      child: child,
    );
  }
}
