import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../../../shared/widgets/form_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with AsyncStateHandlerMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();

    listenAsync(
      provider: authProvider,
      loadingMessage: 'Memproses...',
      onData: (user) {
        if (user != null) ToastHelper.success('Login berhasil!');
      },
      onError: (err, stack) => ToastHelper.error(err.toString()),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastHelper.error('Email dan password wajib diisi');
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
    const greeting = 'Selamat Datang';
    const welcomeGreeting = 'Masuk akun ${AppConstants.appName}';

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(elevation: 0, scrolledUnderElevation: 0),
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
                  label: 'Email',
                  isRequired: true,
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: screenHeight * 0.02),
                FormTextField(
                  label: 'Password',
                  isRequired: true,
                  isObscure: true,
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
          vertical: screenHeight * 0.04,
        ),
        child: _buildSubmitButton('MASUK', screenWidth),
      ),
    );
  }

  Widget _buildSubmitButton(String text, double screenWidth) {
    return GestureDetector(
      onTap: _onSubmit,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        decoration: ShapeDecoration(
          color: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
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
