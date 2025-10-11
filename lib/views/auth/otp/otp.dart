import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/auth/otp/otp_ctrl.dart';

class Otp extends StatelessWidget {
  Otp({super.key, required this.phoneNumber});

  final String phoneNumber;
  final OtpCtrl ctrl = Get.put(OtpCtrl());

  @override
  Widget build(BuildContext context) {
    ctrl.phoneNumber = phoneNumber;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(children: [const SizedBox(height: 80), _buildLogo(context), const SizedBox(height: 60), _buildOtpForm(context), const SizedBox(height: 40), _buildResendOption(context)]),
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
          child: Icon(Icons.verified_user, size: 40, color: Theme.of(context).colorScheme.onPrimary),
        ),
        const SizedBox(height: 24),
        Text('OTP Verification', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Enter the code sent to $phoneNumber', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.2)),
      ],
    );
  }

  Widget _buildOtpForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ENTER OTP',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.8),
        ),
        const SizedBox(height: 8),
        _buildOtpField(context),
        const SizedBox(height: 24),
        _buildTimer(context),
        const SizedBox(height: 32),
        _buildVerifyButton(context),
      ],
    );
  }

  Widget _buildOtpField(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: ctrl.otpController,
        keyboardType: TextInputType.number,
        maxLength: 4,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 8),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0000',
          hintStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3), letterSpacing: 8),
          border: InputBorder.none,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: ctrl.onOtpChanged,
      ),
    );
  }

  Widget _buildTimer(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(ctrl.canResend.value ? 'Didn\'t receive code? ' : 'Resend code in ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          if (!ctrl.canResend.value)
            Text(
              '${ctrl.timerCount.value}s',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
            ),
          if (ctrl.canResend.value)
            GestureDetector(
              onTap: ctrl.resendOtp,
              child: Text(
                'Resend OTP',
                style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: ctrl.isLoading.value ? null : ctrl.verifyOtp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          child: ctrl.isLoading.value
              ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'VERIFY OTP',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.verified, size: 20, color: Theme.of(context).colorScheme.onPrimary),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildResendOption(BuildContext context) {
    return Text(
      'Make sure you enter the correct 4-digit code',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, letterSpacing: 0.5),
      textAlign: TextAlign.center,
    );
  }
}
