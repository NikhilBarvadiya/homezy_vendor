class APIIndex {
  static const vendorBase = "vendors";

  /// Auth
  static const login = '$vendorBase/signIn';
  static const verifyOtp = '$vendorBase/verify-otp';
  static const resendOtp = '$vendorBase/resend-otp';
  static const register = '$vendorBase/signUp';

  /// Profile
  static const getProfile = '$vendorBase/get/profile';
  static const updateProfile = '$vendorBase/update/profile';

  /// Dashboard
  static const dashboard = '$vendorBase/dashboard';
  static const earningsDashboard = '$vendorBase/earnings/dashboard';
  static const reviews = '$vendorBase/reviews';

  /// Chat
  static const sendMessage = '$vendorBase/send-message';
  static const chatHistory = '$vendorBase/chat-history';
  static const chatList = '$vendorBase/chat-list';
  static const markAsRead = '$vendorBase/mark-read';

  /// Orders
  static const acceptOrder = '$vendorBase/orders/accept';
  static const rejectOrder = '$vendorBase/orders/reject';
  static const completeOrder = '$vendorBase/orders/complete';
  static const orderList = '$vendorBase/orders/list';

  /// notifications
  static const myNotifications = '$vendorBase/notifications/my';
  static const markReadNotifications = '$vendorBase/notifications/mark-read';
}
