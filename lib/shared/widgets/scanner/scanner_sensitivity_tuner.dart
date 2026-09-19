import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';

/// Adapts camera zoom to keep detection working when the code is scanned
/// from an awkward angle (e.g. ~45° from above/below/the side) instead of
/// dead-on — perspective distortion at those angles shrinks and skews how
/// much of the code the decoder actually sees, which reads exactly like a
/// string of failed detections. Driven purely by [recordFailure] /
/// [recordSuccess] calls from the scan loop, so it has no camera/widget
/// dependency beyond the [MobileScannerController] it adjusts.
///
/// Two independent responses to a failure streak, alternating so neither
/// starves the other:
///  - **Focus nudge**: a tiny, brief zoom perturbation that forces the
///    camera's continuous autofocus to re-run. Cheap, and fixes the common
///    case where focus "hunted" onto the wrong depth and got stuck — which
///    off-angle shots trigger more often than head-on ones.
///  - **Zoom widening**: steps the zoom out a bit, giving the decoder more
///    surrounding context to reconstruct a code that's too tight/skewed in
///    frame. Slower to help than a focus nudge, but recovers cases the
///    nudge alone can't.
///
/// Kept out of [ScannerView] so these heuristics (thresholds, new
/// strategies) can be tuned or extended — e.g. a future "switch detection
/// format priority" strategy — without touching widget/layout code, and so
/// they're unit-testable without a real camera.
class ScannerSensitivityTuner {
  ScannerSensitivityTuner({
    required MobileScannerController controller,
    this.failThreshold = 6,
    this.checkInterval = const Duration(milliseconds: 800),
    this.focusNudgeCooldown = const Duration(seconds: 3),
  }) : _controller = controller;

  final MobileScannerController _controller;

  /// Consecutive detection failures before a strategy kicks in.
  final int failThreshold;

  /// How often the failure count is checked against [failThreshold].
  final Duration checkInterval;

  /// Minimum time between two focus nudges, so it doesn't dominate every
  /// check cycle and starve zoom widening from ever running.
  final Duration focusNudgeCooldown;

  int _failCount = 0;
  Timer? _timer;
  DateTime? _lastFocusNudge;

  /// Starts periodic evaluation. Call once the controller is ready.
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(checkInterval, (_) => _evaluate());
  }

  void recordFailure() => _failCount++;

  void recordSuccess() => _failCount = 0;

  void dispose() {
    _timer?.cancel();
  }

  void _evaluate() {
    if (_failCount <= failThreshold) return;
    _failCount = 0;

    if (_focusNudgeIsOffCooldown()) {
      _nudgeFocus();
    } else {
      _widenDetectionArea();
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

  void _widenDetectionArea() {
    final currentZoom = _controller.value.zoomScale;
    if (currentZoom <= 0) return;
    _controller.setZoomScale((currentZoom - 0.1).clamp(0.0, 1.0));
  }
}
