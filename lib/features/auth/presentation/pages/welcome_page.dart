import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Landing screen shown once the splash finishes restoring the session and
/// finds no one logged in. No app-name wording here (LoginPage's own header
/// already says "Hatchery") — the entry point doubles as PT Darma Multi
/// Cipta branding: its logo + name sit inside the CTA itself instead of a
/// plain "Login" button, so tapping it reads as "continue with DMC" rather
/// than repeating the word LoginPage already uses.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Image.asset(AssetConstants.logoLauncher, height: 140),
              const Spacer(flex: 4),
              _BrandingButton(onTap: () => context.push('/login')),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandingButton extends StatelessWidget {
  const _BrandingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primaryColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SvgPicture.asset(AssetConstants.logoDarmaMultiCipta),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'PT. DARMA MULTI CIPTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
