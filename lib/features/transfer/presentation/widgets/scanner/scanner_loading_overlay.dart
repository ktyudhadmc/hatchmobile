import 'package:flutter/material.dart';

/// Overlay gelap + spinner yang ditampilkan saat basket sedang di-lookup.
///
/// Dipisah agar bisa digunakan ulang di scanner lain atau di-test secara
/// independen.
class ScannerLoadingOverlay extends StatelessWidget {
  const ScannerLoadingOverlay({
    super.key,
    this.message = 'Looking up basket...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black45,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}