import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../shared/widgets/form/form_text_field.dart';
import '../../../app_update/presentation/providers/app_update_provider.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

/// Maps a login failure to its toast message. Credential-related errors
/// (wrong username/password) are shown as a generic prompt rather than the
/// raw backend message; other errors (network, server) keep their own
/// message since those remain actionable/diagnosable as-is.
String loginErrorMessage(Object error) {
  final isInvalidCredentials =
      error is UnauthorizedException ||
      error is BadRequestException ||
      error is ValidationException;
  return isInvalidCredentials ? 'Please check your input' : error.toString();
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late final ProviderSubscription<AsyncValue<User?>> _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription = ref.listenManual<AsyncValue<User?>>(authProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (user) {
          if (user != null) ToastHelper.success('Login successfully!');
        },
        error: (err, stack) => ToastHelper.error(loginErrorMessage(err)),
      );
    });
  }

  @override
  void dispose() {
    _authSubscription.close();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(authProvider.notifier)
        .login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSubmitting = ref.watch(authProvider).isLoading;

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Solid-color header — logo/app name, in place of an illustration.
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  Positioned(
                    top: 4,
                    left: 4,
                    child: IconButton(
                      onPressed: () => context.canPop()
                          ? context.pop()
                          : context.go('/welcome'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(AssetConstants.logoLauncher),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          AppConstants.appName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Bottom "sheet" — a rounded-top white card holding the form,
            // visually continuing the flow from a modal bottom sheet without
            // actually being one (it's the page body, not an overlay).
            Expanded(
              flex: 6,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    // Fixed — stays put as a bottom-sheet-style handle even
                    // when the form below scrolls (e.g. keyboard open).
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          16,
                          24,
                          24 + MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Please enter your credentials to continue',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF7B7B7B),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormTextField(
                                    label: 'Username',
                                    isRequired: true,
                                    controller: _usernameController,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 16),
                                  FormTextField(
                                    label: 'Password',
                                    isRequired: true,
                                    isPassword: true,
                                    controller: _passwordController,
                                    keyboardType: TextInputType.visiblePassword,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            _buildSubmitButton('LOGIN', screenWidth, isSubmitting),
                            const SizedBox(height: 12),
                            Center(child: _buildVersionLabel(ref)),
                            SizedBox(height: screenHeight * 0.02),
                          ],
                        ),
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

  Widget _buildVersionLabel(WidgetRef ref) {
    final version = ref.watch(currentAppVersionProvider).valueOrNull;
    if (version == null) return const SizedBox.shrink();

    return Text(
      'v$version',
      style: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 11),
    );
  }

  Widget _buildSubmitButton(String text, double screenWidth, bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _onSubmit,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: 16,
        ),
        decoration: ShapeDecoration(
          color: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.4,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  Text(
                    "LOADING...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.04,
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.04,
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
