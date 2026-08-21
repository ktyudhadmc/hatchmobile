import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Draggable bottom sheet that starts collapsed to just [title] and can be
/// dragged — or the handle tapped/dragged — to reveal [contentBuilder]'s
/// scrollable content, up to [maxSizeFraction] of the screen. Reusable
/// wherever a peek-and-expand panel needs to float over full-screen content
/// (e.g. a camera preview).
class ExpandableInfoSheet extends StatefulWidget {
  const ExpandableInfoSheet({
    super.key,
    required this.title,
    required this.contentBuilder,
    this.minSizeFraction = 0.12,
    this.maxSizeFraction = 0.5,
  });

  final String title;
  final Widget Function(BuildContext context, ScrollController scrollController)
  contentBuilder;
  final double minSizeFraction;
  final double maxSizeFraction;

  @override
  State<ExpandableInfoSheet> createState() => _ExpandableInfoSheetState();
}

class _ExpandableInfoSheetState extends State<ExpandableInfoSheet> {
  final _sheetController = DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  void _toggleHandle(double screenHeight) {
    final midpoint = (widget.minSizeFraction + widget.maxSizeFraction) / 2;
    final target = _sheetController.size < midpoint
        ? widget.maxSizeFraction
        : widget.minSizeFraction;

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onDragStart(DragStartDetails details) {}

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    final next = (_sheetController.size - details.delta.dy / screenHeight)
        .clamp(widget.minSizeFraction, widget.maxSizeFraction);
    _sheetController.jumpTo(next);
  }

  void _onDragEnd(DragEndDetails details, double screenHeight) {
    final midpoint = (widget.minSizeFraction + widget.maxSizeFraction) / 2;
    final target = _sheetController.size < midpoint
        ? widget.minSizeFraction
        : widget.maxSizeFraction;

    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: widget.minSizeFraction,
      minChildSize: widget.minSizeFraction,
      maxChildSize: widget.maxSizeFraction,
      snap: true,
      snapSizes: [widget.minSizeFraction, widget.maxSizeFraction],
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _toggleHandle(screenHeight),
                onVerticalDragStart: _onDragStart,
                onVerticalDragUpdate: (d) => _onDragUpdate(d, screenHeight),
                onVerticalDragEnd: (d) => _onDragEnd(d, screenHeight),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Expanded(child: widget.contentBuilder(context, scrollController)),
              SizedBox(height: bottomPadding),
            ],
          ),
        );
      },
    );
  }
}
