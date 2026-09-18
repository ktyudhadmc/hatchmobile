import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Pull-to-refresh wrapper with consistent app styling, so every page wires
/// it up the same way instead of configuring the refresh control by hand.
///
/// Uses [CupertinoSliverRefreshControl] instead of Material's
/// [RefreshIndicator] so the page's own content is what visibly drags down
/// as the user pulls (revealing the spinner above it), rather than a
/// spinner floating over content that stays put.
///
/// [slivers] are the page's content, already in sliver form (e.g.
/// [SliverList], [SliverToBoxAdapter], [SliverFillRemaining]) — this widget
/// just prepends the refresh control and wraps everything in the
/// [CustomScrollView] that both need to share.
class RefreshableView extends StatelessWidget {
  const RefreshableView({
    super.key,
    required this.onRefresh,
    required this.slivers,
  });

  final Future<void> Function() onRefresh;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: onRefresh,
          builder: (
            context,
            refreshState,
            pulledExtent,
            refreshTriggerPullDistance,
            refreshIndicatorExtent,
          ) {
            // Anchored to the bottom of the growing pull area — right above
            // where the content starts — instead of centered in it, so the
            // spinner stays put as the user keeps pulling further instead of
            // drifting down the screen with them.
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CupertinoActivityIndicator(
                  color: AppTheme.primaryColor,
                  radius: 12,
                ),
              ),
            );
          },
        ),
        ...slivers,
      ],
    );
  }
}
