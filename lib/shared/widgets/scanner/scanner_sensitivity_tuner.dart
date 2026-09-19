import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

/// Adapts camera zoom/focus to keep detection working when a code is hard
/// for the decoder to read — off-angle (~45° from above/below/the side)
/// shots, or a code that's simply too small/dense in frame (e.g. a QR with
/// a logo cut into the center, leaving little spare margin). Both read
/// exactly like a string of failed detections, which is all this tuner
/// sees: it's driven purely by [recordFailure]/[recordSuccess] calls from
/// the scan loop, with no camera/widget dependency beyond the
/// [MobileScannerController] it adjusts.
///
/// On a sustained failure streak, it cycles through independent recovery
/// strategies rather than committing to just one — a fixed "always zoom
/// out" policy actively hurts a code that's too small to resolve, so it
/// needs a chance to zoom in too:
///  - **Focus nudge**: a tiny, brief zoom perturbation that forces the
///    camera's continuous autofocus to re-run. Cheap, and fixes the common
///    case where focus "hunted" onto the wrong depth and got stuck.
///  - **Zoom in**: gives the decoder more pixels per module, for a code
///    that's dense/small/logo-occluded and simply illegible at the current
///    distance.
///  - **Zoom out**: gives the decoder more surrounding context, for a code
///    that's too tight or skewed in frame (the off-angle case).
///
/// If none of that resolves it after a few full cycles, zoom is reset back
/// to baseline so the tuner doesn't stay stuck at whichever extreme it last
/// tried while the user repositions.
///
/// Kept out of [ScannerView] so these heuristics (thresholds, new
/// strategies) can be tuned or extended without touching widget/layout
/// code, and so they're unit-testable without a real camera.
class ScannerSensitivityTuner {
  ScannerSensitivityTuner({
    required MobileScannerController controller,
    this.failThreshold = 6,
    this.checkInterval = const Duration(milliseconds: 800),
    this.focusNudgeCooldown = const Duration(seconds: 3),
    this.zoomStep = 0.08,
    this.cyclesBeforeReset = 4,
  }) : _controller = controller;

  final MobileScannerController _controller;

  /// Consecutive detection failures before the next strategy kicks in.
  final int failThreshold;

  /// How often the failure count is checked against [failThreshold].
  final Duration checkInterval;

  /// Minimum time between two focus nudges — it's the cheapest strategy,
  /// so without a cooldown it would dominate the rotation.
  final Duration focusNudgeCooldown;

  /// How much each zoom-in/zoom-out step changes [zoomScale] by.
  final double zoomStep;

  /// Full strategy-rotation cycles to try before giving up and resetting
  /// zoom to baseline (0.0), so a wrong guess doesn't strand the camera at
  /// an unusable zoom level indefinitely.
  final int cyclesBeforeReset;

  static const List<_Strategy> _rotation = [
    _Strategy.focusNudge,
    _Strategy.zoomIn,
    _Strategy.zoomOut,
  ];

  int _failCount = 0;
  int _strategyIndex = 0;
  int _attemptsSinceSuccess = 0;
  Timer? _timer;
  DateTime? _lastFocusNudge;

  /// Starts periodic evaluation. Call once the controller is ready.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) => _evaluate());
  }

  void recordFailure() => _failCount++;

  void recordSuccess() {
    _failCount = 0;
    _strategyIndex = 0;
    _attemptsSinceSuccess = 0;
  }

  void dispose() {
    _timer?.cancel();
  }

  void _evaluate() {
    if (_failCount <= failThreshold) return;
    _failCount = 0;

    if (_attemptsSinceSuccess >= _rotation.length * cyclesBeforeReset) {
      _resetZoom();
      return;
    }
    _attemptsSinceSuccess++;

    final strategy = _rotation[_strategyIndex % _rotation.length];
    _strategyIndex++;

    switch (strategy) {
      case _Strategy.focusNudge:
        if (_focusNudgeIsOffCooldown()) {
          _nudgeFocus();
        } else {
          _zoomBy(zoomStep); // cooldown active — try zooming in instead
        }
      case _Strategy.zoomIn:
        _zoomBy(zoomStep);
      case _Strategy.zoomOut:
        _zoomBy(-zoomStep);
    }
  }

  bool _focusNudgeIsOffCooldown() {
    final last = _lastFocusNudge;
    return last == null || DateTime.now().difference(last) >= focusNudgeCooldown;
  }

  Future<void> _nudgeFocus() async {
    _lastFocusNudge = DateTime.now();

    final zoom = _controller.value.zoomScale;
    final nudged = (zoom + 0.02).clamp(0.0, 1.0);
    if (nudged == zoom) return;

    await _controller.setZoomScale(nudged);
    await Future.delayed(const Duration(milliseconds: 120));
    await _controller.setZoomScale(zoom);
  }

  void _zoomBy(double delta) {
    final current = _controller.value.zoomScale;
    _controller.setZoomScale((current + delta).clamp(0.0, 1.0));
  }

  void _resetZoom() {
    _attemptsSinceSuccess = 0;
    _strategyIndex = 0;
    _controller.setZoomScale(0.0);
  }
}

enum _Strategy { focusNudge, zoomIn, zoomOut }
