class APIIndex {
  static const vendorBase = "vendors";

  /// Auth
  static const login = '$vendorBase/signIn';
  static const verifyOtp = '$vendorBase/verify-otp';
  static const resendOtp = '$vendorBase/resend-otp';
  static const register = '$vendorBase/signUp';
  static const getProfile = '$vendorBase/get/profile'; // done
  static const updateProfile = '$vendorBase/update/profile'; // done
  static const dashboard = '$vendorBase/dashboard';
  static const earningsDashboard = '$vendorBase/earnings/dashboard';
  static const reviews = '$vendorBase/reviews';
}
