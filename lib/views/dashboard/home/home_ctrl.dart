import 'package:get/get.dart';
import 'package:homezy_vendor/utils/toaster.dart';
import 'package:homezy_vendor/views/auth/auth_service.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxMap<String, dynamic> vendorData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> analytics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> earnings = <String, dynamic>{}.obs;
  final RxList<dynamic> recentReviews = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading(true);
      hasError(false);
      await Future.wait([loadVendorDashboard(), loadEarningsDashboard(), loadRecentReviews()], eagerError: true);
    } catch (e) {
      hasError(true);
      toaster.error('Failed to load dashboard data');
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadVendorDashboard() async {
    try {
      final response = await _authService.getVendorDashboard();
      if (response != null && response is Map) {
        vendorData.value = response['vendor'] ?? {};
        analytics.value = response['analytics'] ?? {};
      }
    } catch (e) {
      toaster.error('Error loading vendor data');
      rethrow;
    }
  }

  Future<void> loadEarningsDashboard() async {
    try {
      final response = await _authService.getEarningsDashboard();
      if (response != null && response is Map) {
        earnings.value = Map<String, dynamic>.from(response);
      }
    } catch (e) {
      toaster.error('Error loading earnings data');
      rethrow;
    }
  }

  Future<void> loadRecentReviews() async {
    try {
      final response = await _authService.getVendorReviews(page: 1, limit: 5);
      if (response != null && response is Map) {
        recentReviews.value = response['reviews'] ?? [];
      }
    } catch (e) {
      toaster.error('Error loading reviews');
      rethrow;
    }
  }

  // Vendor Data Getters with null safety
  String get vendorName => vendorData['name']?.toString() ?? 'Vendor Name';

  String get businessName => vendorData['businessName']?.toString() ?? 'Business Name';

  String get profileImage => vendorData['image']?.toString() ?? '';

  double get rating {
    final ratingValue = vendorData['overallRating'];
    if (ratingValue is num) return ratingValue.toDouble();
    if (ratingValue is String) return double.tryParse(ratingValue) ?? 0.0;
    return 0.0;
  }

  int get completedJobs {
    final jobs = vendorData['completedJobs'];
    if (jobs is num) return jobs.toInt();
    if (jobs is String) return int.tryParse(jobs) ?? 0;
    return 0;
  }

  bool get isApproved => vendorData['isApproved'] == true;

  String get verificationStatus => vendorData['verificationStatus']?.toString() ?? 'pending';

  // Analytics Getters with null safety
  int get totalOrders {
    final orders = analytics['orders']?['total'];
    if (orders is num) return orders.toInt();
    if (orders is String) return int.tryParse(orders) ?? 0;
    return 0;
  }

  int get pendingOrders {
    final orders = analytics['orders']?['pending'];
    if (orders is num) return orders.toInt();
    if (orders is String) return int.tryParse(orders) ?? 0;
    return 0;
  }

  int get acceptedOrders {
    final orders = analytics['orders']?['accepted'];
    if (orders is num) return orders.toInt();
    if (orders is String) return int.tryParse(orders) ?? 0;
    return 0;
  }

  double get totalEarnings {
    final earningsValue = earnings['totalEarnings']?['total'];
    if (earningsValue is num) return earningsValue.toDouble();
    if (earningsValue is String) return double.tryParse(earningsValue) ?? 0.0;
    return 0.0;
  }

  double get completionRate {
    final rate = analytics['performance']?['completionRate'];
    if (rate is num) return rate.toDouble();
    if (rate is String) return double.tryParse(rate) ?? 0.0;
    return 0.0;
  }

  double get responseRate {
    final rate = analytics['performance']?['responseRate'];
    if (rate is num) return rate.toDouble();
    if (rate is String) return double.tryParse(rate) ?? 0.0;
    return 0.0;
  }
}
