import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/config/session.dart';
import 'package:homenest_vendor/utils/service/bookings_service.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:homenest_vendor/views/auth/auth_service.dart';

class AvailableBookingsCtrl extends GetxController {
  final BookingsService _bookingsService = Get.find<BookingsService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<dynamic> availableBookings = <dynamic>[].obs;
  final RxBool isBookingsLoading = false.obs, isRefreshing = false.obs;
  final RxList<dynamic> allServices = <dynamic>[].obs, selectedServices = <dynamic>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isServicesLoading = false.obs, hasMoreServices = true.obs, isUpdating = false.obs;
  final RxBool isRejected = false.obs, isAccepted = false.obs;
  final RxInt currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      await Future.wait([getAvailableBookings(), getServices(), getLocalService()], eagerError: true);
    } catch (e) {
      toaster.error('Failed to load data');
    }
  }

  Future<void> getLocalService() async {
    dynamic userData = await read(AppSession.userData);
    if (userData != null && userData["services"] != null) {
      List services = userData["services"] ?? [];
      if (services.isNotEmpty) {
        for (int i = 0; i < services.length; i++) {
          dynamic subcategory = services[i]["subcategory"];
          final serviceIndex = selectedServices.indexWhere((s) => s['_id'] == services[i]['_id']);
          if (serviceIndex != -1) {
            final selectedService = selectedServices[serviceIndex];
            final selectedSubcategories = List<dynamic>.from(selectedService['selectedSubcategories'] ?? []);
            final isSelected = selectedSubcategories.any((sub) => sub != null && sub['_id'] != null && subcategory != null && sub['_id'] == subcategory['_id']);
            if (isSelected) {
              selectedSubcategories.removeWhere((sub) => sub['_id'] == subcategory['_id']);
            } else {
              if (subcategory != null) {
                selectedSubcategories.add(subcategory);
              }
            }
            selectedServices[serviceIndex] = {...selectedService, 'selectedSubcategories': selectedSubcategories};
            if (selectedSubcategories.isEmpty) {
              selectedServices.removeAt(serviceIndex);
            }
          } else {
            selectedServices.add({
              ...services[i],
              'selectedSubcategories': subcategory != null ? [subcategory] : [],
            });
          }
          if (!selectedServices.any((s) => s['_id'] == services[i]['_id'])) {
            selectedServices.add(services[i]);
          }
        }
      }
    }
    update();
  }

  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    getServices();
  }

  void searchServices(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    getServices();
  }

  void unselectService(dynamic service) {
    selectedServices.removeWhere((s) => s['_id'] == service['_id']);
  }

  void clearSelectedServices() {
    selectedServices.clear();
  }

  void toggleSubcategorySelection(dynamic service, dynamic subcategory) {
    final serviceIndex = selectedServices.indexWhere((s) => s['_id'] == service['_id']);
    if (serviceIndex != -1) {
      final selectedService = selectedServices[serviceIndex];
      final selectedSubcategories = List<dynamic>.from(selectedService['selectedSubcategories'] ?? []);
      final isSelected = selectedSubcategories.any((sub) => sub['_id'] != null && sub['_id'] == subcategory['_id']);
      if (isSelected) {
        selectedSubcategories.removeWhere((sub) => sub['_id'] == subcategory['_id']);
      } else {
        selectedSubcategories.add(subcategory);
      }
      selectedServices[serviceIndex] = {...selectedService, 'selectedSubcategories': selectedSubcategories};
      if (selectedSubcategories.isEmpty) {
        selectedServices.removeAt(serviceIndex);
      }
    } else {
      selectedServices.add({
        ...service,
        'selectedSubcategories': [subcategory],
      });
    }
  }

  bool isSubcategorySelected(dynamic service, dynamic subcategory) {
    final selectedService = selectedServices.firstWhere((s) => s['_id'] == service['_id'], orElse: () => {'selectedSubcategories': []});
    final selectedSubcategories = List<dynamic>.from(selectedService['selectedSubcategories'] ?? []);
    return selectedSubcategories.any((sub) => sub['_id'] == subcategory['_id']);
  }

  List<dynamic> getSelectedSubcategories(dynamic service) {
    final selectedService = selectedServices.firstWhere((s) => s['_id'] == service['_id'], orElse: () => {'selectedSubcategories': []});
    return List<dynamic>.from(selectedService['selectedSubcategories'] ?? []);
  }

  Future<void> loadMoreServices() async {
    if (!isServicesLoading.value && hasMoreServices.value) {
      await getServices(loadMore: true);
    }
  }

  Future<void> getAvailableBookings() async {
    try {
      isBookingsLoading(true);
      final response = await _bookingsService.getAvailableBookings();
      if (response != null && response != null) {
        availableBookings.assignAll(response);
      }
    } catch (e) {
      toaster.error('Failed to load available bookings: ${e.toString()}');
    } finally {
      isBookingsLoading(false);
    }
  }

  void toggleFullDetails(String bookingId) {
    final index = availableBookings.indexWhere((booking) => booking['_id'] == bookingId);
    if (index != -1) {
      availableBookings[index]['isExpanded'] = !(availableBookings[index]['isExpanded'] ?? false);
      availableBookings.refresh();
    }
  }

  Future<void> refreshBookings() async {
    try {
      isRefreshing(true);
      await loadData();
    } finally {
      isRefreshing(false);
    }
  }

  Future<void> updateProfile() async {
    try {
      isUpdating(true);
      final formData = dio.FormData.fromMap({
        "services": selectedServices.expand((s) {
          final subCats = s["subCategories"] ?? [];
          if (subCats.isEmpty) {
            return [
              {"_id": s["_id"], "name": s["name"], "description": s["description"], "category": s["_id"], "subcategory": s["_id"], "basePrice": 0},
            ];
          } else {
            return subCats.map((sub) {
              final basePriceRaw = sub["basePrice"];
              num basePrice = 0;
              if (basePriceRaw is num) {
                basePrice = basePriceRaw;
              } else if (basePriceRaw is String) {
                basePrice = num.tryParse(basePriceRaw) ?? 0;
              }
              return {"_id": s["_id"], "name": s["name"], "description": s["description"], "category": s["_id"], "subcategory": sub["_id"], "basePrice": basePrice.toInt()};
            });
          }
        }).toList(),
      });
      final response = await _authService.updateProfile(formData);
      if (response != null) {
        await write(AppSession.userData, response);
        toaster.success('Profile updated successfully');
        Get.close(1);
      } else {
        toaster.error('Failed to update profile');
      }
    } catch (e) {
      toaster.error('Error updating profile: $e');
    } finally {
      isUpdating(false);
    }
  }

  Future<void> getServices({bool loadMore = false}) async {
    try {
      if (loadMore) {
        if (!hasMoreServices.value) return;
        currentPage.value++;
      } else {
        isServicesLoading(true);
        currentPage.value = 1;
        hasMoreServices.value = true;
      }
      final response = await _bookingsService.getServicesList(page: currentPage.value, limit: 10, search: searchQuery.value);
      if (response != null && response['docs'] != null) {
        final newNotifications = response['docs'] as List<dynamic>;
        if (loadMore) {
          allServices.addAll(newNotifications);
        } else {
          allServices.assignAll(newNotifications);
        }
        hasMoreServices.value = newNotifications.length == 10;
      }
    } catch (e) {
      toaster.error('Failed to load services: ${e.toString()}');
    } finally {
      isServicesLoading(false);
    }
  }

  List<dynamic> get filteredBookings {
    var filtered = availableBookings.where((booking) {
      if (searchQuery.isNotEmpty) {
        final searchLower = searchQuery.value.toLowerCase();
        final matchesSearch =
            booking['customer']?['name']?.toLowerCase().contains(searchLower) == true ||
            booking['subcategory']?['name']?.toLowerCase().contains(searchLower) == true ||
            booking['customer']?['mobileNo']?.contains(searchQuery.value) == true;
        if (!matchesSearch) return false;
      }
      return true;
    }).toList();
    filtered.sort((a, b) {
      if (a['urgency'] == 'high' && b['urgency'] != 'high') return -1;
      if (b['urgency'] == 'high' && a['urgency'] != 'high') return 1;
      final aDate = _parseDateTime(a['slot']?['date']);
      final bDate = _parseDateTime(b['slot']?['date']);
      return aDate.compareTo(bDate);
    });
    return filtered;
  }

  DateTime _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }
    try {
      if (RegExp(r'^\d{2}:\d{2}$').hasMatch(dateString)) {
        final now = DateTime.now();
        return DateTime.parse('${now.toIso8601String().split('T')[0]}T$dateString:00');
      }
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }

  void toggleServiceSelection(dynamic service) {
    final isSelected = selectedServices.any((s) => s['_id'] == service['_id']);
    if (isSelected) {
      selectedServices.removeWhere((s) => s['_id'] == service['_id']);
    } else {
      selectedServices.add(service);
    }
  }

  String formatBookingDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = date.difference(now);
      if (difference.inDays == 0) return 'Today';
      if (difference.inDays == 1) return 'Tomorrow';
      if (difference.inDays < 7) return 'In ${difference.inDays} days';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String formatBookingTime(String timeString) {
    try {
      final time = DateTime.parse(timeString);
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid time';
    }
  }

  Future<bool> acceptBooking(String bookingId) async {
    try {
      isAccepted(true);
      dynamic response = await _bookingsService.updateVendorServices(orderId: bookingId, status: "accepted");
      if (response != null) {
        availableBookings.removeWhere((order) => order['_id'] == bookingId);
        toaster.success('Booking accepted successfully');
      }
      return true;
    } catch (e) {
      toaster.error('Failed to accept booking: ${e.toString()}');
      return false;
    } finally {
      isAccepted(false);
    }
  }

  Future<bool> rejectBooking(String bookingId) async {
    try {
      isRejected(true);
      dynamic response = _bookingsService.updateVendorServices(orderId: bookingId, status: "rejected");
      if (response != null) {
        availableBookings.removeWhere((order) => order['_id'] == bookingId);
        toaster.success('Booking rejected');
      }
      return true;
    } catch (e) {
      toaster.error('Failed to reject booking: ${e.toString()}');
      return false;
    } finally {
      isRejected(false);
    }
  }
}
