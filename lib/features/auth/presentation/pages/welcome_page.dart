import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/theme/app_theme.dart';

/// Landing screen shown once the splash finishes restoring the session and
/// finds no one logged in. Visually a static continuation of [SplashPage]
/// (same logo + PT branding), with a "Login" button added above the
/// branding to hand off to the actual credentials form.
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
              Image.asset(AssetConstants.logoLauncher, height: 120),
              const SizedBox(height: 12),
              const Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    constraints: const BoxConstraints(
                      maxWidth: 32,
                      minWidth: 24,
                    ),
                    child: SvgPicture.asset(AssetConstants.logoDarmaMultiCipta),
                  ),
                  const Text(
                    'PT. DARMA MULTI CIPTA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
