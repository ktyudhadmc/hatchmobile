import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

/// Notched bottom bar with Home (left) and Profile (right) — the notch is
/// where [ScanFab] docks. Used together on every top-level page, e.g.:
///
/// ```dart
/// Scaffold(
///   floatingActionButton: const ScanFab(),
///   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
///   bottomNavigationBar: BottomBarNavigation(currentRoute: currentRoute),
/// )
/// ```
class BottomBarNavigation extends StatelessWidget {
  const BottomBarNavigation({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      elevation: 10,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.history,
            label: 'History',
            isActive: currentRoute == '/home',
            onTap: () => context.go('/home'),
          ),
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: currentRoute == '/profile',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryColor : Colors.black54;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontFamily: AppTheme.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Orange circular FAB that docks into [BottomBarNavigation]'s notch.
///
/// Goes to `/scan` (not a `push`) because that route hosts the live
/// scanner — pushing a second scanner route on top would leave two
/// [TransferScannerView]s alive at once, both reacting to the same scan,
/// which double-fires the scan -> confirm flow. `go` replaces the stack
/// instead of stacking on it.
class ScanFab extends StatelessWidget {
  const ScanFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      shape: const CircleBorder(),
      backgroundColor: AppTheme.primaryColor,
      onPressed: () => context.go('/scan'),
      child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
    );
  }
}
