import 'package:get/get.dart';
import 'package:homezy_vendor/utils/service/order_service.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class OrdersCtrl extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  final RxList<dynamic> orders = <dynamic>[].obs;
  final RxList<dynamic> pendingOrders = <dynamic>[].obs;
  final RxList<dynamic> acceptedOrders = <dynamic>[].obs;
  final RxList<dynamic> completedOrders = <dynamic>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString selectedStatus = 'all'.obs;
  final RxString selectedDateFilter = 'all'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  final tabs = ['all', 'pending', 'assigned', 'accepted', 'rejected', 'completed'];

  @override
  void onInit() {
    super.onInit();
    getOrders();
  }

  Future<void> getOrders({bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
      } else {
        isLoading.value = true;
      }
      final Map<String, dynamic> request = {};
      if (selectedStatus.value != 'all') {
        request['status'] = selectedStatus.value;
      }
      if (startDate.value != null && endDate.value != null) {
        request['startDate'] = startDate.value!.toIso8601String();
        request['endDate'] = endDate.value!.toIso8601String();
      }
      final response = await _orderService.getOrders(request);
      if (response != null) {
        orders.assignAll(response);
        _categorizeOrders();
      }
    } catch (e) {
      toaster.error('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  void _categorizeOrders() {
    pendingOrders.value = orders.where((order) => order['status'] == 'pending').toList();
    acceptedOrders.value = orders.where((order) => order['status'] == 'accepted').toList();
    completedOrders.value = orders.where((order) => order['status'] == 'completed').toList();
  }

  Future<bool> acceptOrder(String orderId) async {
    try {
      isActionLoading.value = true;
      final response = await _orderService.acceptOrder({'orderId': orderId});
      if (response != null) {
        final index = orders.indexWhere((order) => order['_id'] == orderId);
        if (index != -1) {
          orders[index] = response;
          _categorizeOrders();
        }
        return true;
      }
      return false;
    } catch (e) {
      toaster.error('Failed to accept order: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> rejectOrder(String orderId) async {
    try {
      isActionLoading.value = true;
      final response = await _orderService.rejectOrder({'orderId': orderId});
      if (response != null) {
        final index = orders.indexWhere((order) => order['_id'] == orderId);
        if (index != -1) {
          orders[index] = response;
          _categorizeOrders();
        }
        return true;
      }
      return false;
    } catch (e) {
      toaster.error('Failed to reject order: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> completeOrder(String orderId) async {
    try {
      isActionLoading.value = true;
      final response = await _orderService.completeOrder({'orderId': orderId});
      if (response != null) {
        final index = orders.indexWhere((order) => order['_id'] == orderId);
        if (index != -1) {
          orders[index] = response;
          _categorizeOrders();
        }
        return true;
      }
      return false;
    } catch (e) {
      toaster.error('Failed to complete order: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  List<dynamic> get filteredOrders {
    switch (selectedStatus.value) {
      case 'pending':
        return pendingOrders;
      case 'accepted':
        return acceptedOrders;
      case 'completed':
        return completedOrders;
      default:
        return orders;
    }
  }

  void updateStatusFilter(String status) {
    selectedStatus.value = status;
    getOrders();
  }

  void updateDateFilter(String filter, {DateTime? customStart, DateTime? customEnd}) {
    selectedDateFilter.value = filter;
    if (filter == 'custom') {
      startDate.value = customStart;
      endDate.value = customEnd;
    }
    getOrders();
  }

  void updateDateRange(DateTime start, DateTime end) {
    startDate.value = start;
    endDate.value = end;
  }

  void clearFilters() {
    selectedStatus.value = 'all';
    selectedDateFilter.value = 'all';
    startDate.value = null;
    endDate.value = null;
    getOrders();
  }

  bool get hasActiveFilters {
    return selectedStatus.value != 'all' || selectedDateFilter.value != 'all';
  }
}
