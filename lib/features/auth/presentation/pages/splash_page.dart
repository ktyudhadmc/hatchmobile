import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/asset_constants.dart';

/// Shown while [AuthNotifier] restores the session on app start. Unlike a
/// fixed-delay splash, navigation away from here is driven entirely by the
/// router's `redirect` (see core/router/app_router.dart) once the auth
/// state resolves — this page only plays the entrance animation.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  // late final Animation<double> _fadeAnimation;
  // late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    // );

    // _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(
          children: [
            // Center(
            //   child: AnimatedBuilder(
            //     animation: _animationController,
            //     builder: (context, child) {
            //       return FadeTransition(
            //         opacity: _fadeAnimation,
            //         child: ScaleTransition(
            //           scale: _scaleAnimation,
            //           child: child,
            //         ),
            //       );
            //     },
            //     child: Image.asset(AssetConstants.logoLauncher, height: 120),
            //     // child: SvgPicture.asset(AssetConstants.logoPeternak, height: 120),
            //   ),
            // ),
            Center(
              child: Image.asset(AssetConstants.logoLauncher, height: 120),
            ),
            Positioned(
              bottom: 72,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      constraints: const BoxConstraints(
                        maxWidth: 32,
                        minWidth: 24,
                      ),
                      child: SvgPicture.asset(
                        AssetConstants.logoDarmaMultiCipta,
                      ),
                    ),
                    const Text(
                      'PT. DARMA MULTI CIPTA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
