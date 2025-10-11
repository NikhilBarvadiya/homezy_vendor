class APIIndex {
  static const vendorBase = "vendors";

  /// Auth
  static const login = '$vendorBase/signIn'; // done
  static const verifyOtp = '$vendorBase/verify-otp'; // done
  static const resendOtp = '$vendorBase/resend-otp'; // done
  static const register = '$vendorBase/signUp'; // done
  static const getProfile = '$vendorBase/get/profile';
  static const updateProfile = '$vendorBase/update-profile';
}
