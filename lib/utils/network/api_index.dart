class APIIndex {
  static const vendorBase = "vendors";
  static const userBase = "users";
  static const adminBase = "admin";

  /// Auth
  static const login = '$vendorBase/signIn';
  static const verifyOtp = '$vendorBase/verify-otp';
  static const resendOtp = '$vendorBase/resend-otp';
  static const register = '$vendorBase/signUp';

  /// Services
  static const servicesList = '$adminBase/services/list';
  static const getAvailableBookings = '$vendorBase/getAvailableBookings';

  /// Profile
  static const getProfile = '$vendorBase/get/profile';
  static const updateProfile = '$vendorBase/update/profile';

  /// Slots
  static const setWeeklySlots = '$vendorBase/slots/set-weekly';
  static const weeklySlots = '$vendorBase/slots/weekly';
  static const updateAvailability = '$vendorBase/slots/update-availability';

  /// Dashboard
  static const dashboard = '$vendorBase/dashboard';
  static const earningsDashboard = '$vendorBase/earnings/dashboard';
  static const reviews = '$vendorBase/reviews';

  /// Chat
  static const sendMessage = '$vendorBase/vendor/send-message';
  static const chatHistory = '$vendorBase/vendor/chat-history';
  static const markAsRead = '$vendorBase/vendor/mark-read';

  /// Orders
  static const orderList = '$userBase/getVendorOrdersByStatus';
  static const updateVendorServices = '$userBase/updateOrder';
  static const paymentCollectCash = '$vendorBase/payments/collect-cash';

  /// notifications
  static const myNotifications = '$vendorBase/notifications/my';
  static const markReadNotifications = '$vendorBase/notifications/mark-read';
}

// Homezy Vendor Application
// Set Weekly Slots UI with API Calling (Slot Management)
// Get & Update Weekly Slots UI with API Calling (Slot Management)