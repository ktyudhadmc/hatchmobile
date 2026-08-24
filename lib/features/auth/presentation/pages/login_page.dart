import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../shared/widgets/form/form_text_field.dart';
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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // Not the shared listenAsync/DialogHelper loading dialog: a successful
  // login immediately triggers go_router's redirect to /scan, which can
  // unmount this page before the dialog's deferred pop runs — leaving it
  // stuck open on top of /scan forever. An inline spinner on the submit
  // button itself sidesteps the whole class of bug (no dialog, no
  // Navigator involved).
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
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastHelper.error('Please enter email and password');
      return;
    }

    ref
        .read(authProvider.notifier)
        .login(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    const greeting = AppConstants.appName;
    const welcomeGreeting = 'Please enter your credentials to continue';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSubmitting = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(elevation: 0, scrolledUnderElevation: 0),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AssetConstants.logoPeternak,
              height: screenHeight * 0.08,
            ),
            SizedBox(height: screenHeight * 0.04),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  welcomeGreeting,
                  style: TextStyle(
                    fontSize: screenHeight * 0.015,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                FormTextField(
                  label: 'Username',
                  isRequired: true,
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: screenHeight * 0.02),
                FormTextField(
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  controller: _passwordController,
                  keyboardType: TextInputType.visiblePassword,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: screenHeight * 0.08,
        ),
        child: _buildSubmitButton('MASUK', screenWidth, isSubmitting),
      ),
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
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
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
