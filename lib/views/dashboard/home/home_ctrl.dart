import 'package:get/get.dart';
import 'package:homenest_vendor/utils/config/session.dart';
import 'package:homenest_vendor/utils/service/socket_service.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/views/auth/auth_service.dart';

class HomeCtrl extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxMap<String, dynamic> vendorData = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> analytics = <String, dynamic>{}.obs;
  final RxMap<String, dynamic> earnings = <String, dynamic>{}.obs;
  final RxList<dynamic> recentReviews = <dynamic>[].obs;
  final RxBool isLoading = false.obs, hasError = false.obs, hasMoreReviews = true.obs;
  final RxInt totalReviews = 0.obs, currentPage = 1.obs;
  final int reviewsPerPage = 10;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading(true);
      hasError(false);
      dynamic userData = await read(AppSession.userData);
      dynamic token = await read(AppSession.token);
      SocketService().connectToServer(token, userData);
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

  Future<Map<String, dynamic>?> loadRecentReviews({int page = 1, int limit = 10}) async {
    try {
      final response = await _authService.getVendorReviews(page: page, limit: limit);
      if (response != null && response is Map) {
        final reviews = response['reviews'] ?? [];
        final total = response['total'] ?? 0;
        final totalPages = response['totalPages'] ?? 1;
        totalReviews.value = total;
        if (page == 1) {
          recentReviews.value = reviews;
        } else {
          recentReviews.addAll(reviews);
        }
        hasMoreReviews.value = page < totalPages;
        return {'reviews': reviews, 'total': total, 'totalPages': totalPages, 'hasMore': page < totalPages};
      }
      return null;
    } catch (e) {
      toaster.error('Error loading reviews');
      rethrow;
    }
  }

  Future<void> loadMoreReviews() async {
    if (!hasMoreReviews.value) return;
    try {
      currentPage.value++;
      final response = await loadRecentReviews(page: currentPage.value, limit: reviewsPerPage);
      if (response != null) {
        final hasMore = response['hasMore'] ?? false;
        hasMoreReviews.value = hasMore;
      }
    } catch (e) {
      currentPage.value--;
      toaster.error('Failed to load more reviews');
    }
  }

  Future<void> refreshReviews() async {
    currentPage.value = 1;
    hasMoreReviews.value = true;
    await loadRecentReviews(page: 1, limit: reviewsPerPage);
  }

  Future<void> reviewsRespond({required String responseText, required String reviewId}) async {
    try {
      final response = await _authService.reviewsRespond(responseText: responseText, reviewId: reviewId);
      if (response != null && response is Map) {
        final index = recentReviews.indexWhere((review) => review['_id'] == reviewId);
        if (index != -1) {
          recentReviews[index]['vendorResponse'] = {'responseText': responseText, 'respondedAt': DateTime.now().toIso8601String()};
          recentReviews.refresh();
        }
      }
    } catch (e) {
      toaster.error('Error responding to review');
      rethrow;
    }
  }

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
