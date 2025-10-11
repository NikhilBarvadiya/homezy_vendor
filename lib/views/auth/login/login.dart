import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/login/login_ctrl.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final LoginCtrl ctrl = Get.put(LoginCtrl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [const SizedBox(height: 100), _buildLogo(context), const SizedBox(height: 80), _buildLoginForm(context), const SizedBox(height: 60), _buildRegisterOption(context)]),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)]),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Icon(Icons.work_outline, size: 40, color: Theme.of(context).colorScheme.onPrimary),
        ),
        const SizedBox(height: 24),
        Text('Welcome Back', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text('Sign in to continue', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(children: [_buildPhoneField(context), const SizedBox(height: 24), _buildLoginButton(context), const SizedBox(height: 16), _buildTermsText(context)]);
  }

  Widget _buildPhoneField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number', style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
          ),
          child: TextFormField(
            controller: ctrl.phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter your number',
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              prefixIcon: GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    spacing: 4.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(CupertinoIcons.phone, size: 20),
                      Container(height: 24, width: 1, color: Theme.of(context).colorScheme.outline, margin: const EdgeInsets.only(left: 8, right: 8)),
                    ],
                  ),
                ),
              ),
            ),
            onChanged: (value) => ctrl.update(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : ctrl.login,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: ctrl.isLoading.value
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
              : Text(
                  'Continue',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                ),
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'By continuing, you agree to our Terms and Privacy Policy',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRegisterOption(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        GestureDetector(
          onTap: ctrl.goToRegister,
          child: Text(
            'Register',
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
