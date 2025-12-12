import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:homenest_vendor/utils/service/order_service.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class OrdersCtrl extends GetxController {
  final OrderService _orderService = Get.find<OrderService>();

  final RxList<dynamic> orders = <dynamic>[].obs, filteredOrders = <dynamic>[].obs;
  final RxBool isLoading = false.obs, isActionLoading = false.obs, hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxString selectedStatus = 'all'.obs, selectedDateFilter = 'all'.obs;
  final Rx<DateTime?> startDate = Rx<DateTime?>(null), endDate = Rx<DateTime?>(null);

  final tabs = ['all', 'accepted', 'rejected', 'completed'];
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    getOrders();
  }

  Future<void> getOrders({bool isRefresh = false, bool loadMore = false}) async {
    try {
      if (isRefresh) {
        currentPage.value = 1;
        hasMore.value = true;
      } else if (loadMore) {
        if (!hasMore.value) return;
        currentPage.value++;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
      }
      final Map<String, dynamic> request = {'page': currentPage.value, 'limit': _limit};
      if (selectedStatus.value != 'all') {
        switch (selectedStatus.value) {
          case 'rejected':
            request['status'] = ['rejected'];
            break;
          case 'completed':
            request['status'] = ['completed'];
            break;
          default:
            request['status'] = [selectedStatus.value];
        }
      } else {
        request['status'] = ['pending', 'accepted'];
      }
      if (selectedDateFilter.value != 'all' && startDate.value != null && endDate.value != null) {
        request['startDate'] = startDate.value!.toIso8601String();
        request['endDate'] = endDate.value!.toIso8601String();
      }
      final response = await _orderService.getOrders(request);
      if (response != null && response['orders'] != null) {
        final newOrders = response['orders'] as List<dynamic>;
        if (loadMore) {
          orders.addAll(newOrders);
        } else {
          orders.assignAll(newOrders);
        }
        hasMore.value = newOrders.length == _limit;
        _filterOrders();
      }
    } catch (e) {
      toaster.error('Failed to load orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _filterOrders() {
    if (selectedStatus.value == 'all') {
      filteredOrders.assignAll(orders.where((order) => order['status'] == 'pending' || order['status'] == 'accepted').toList());
    } else if (selectedStatus.value == 'pending') {
      filteredOrders.assignAll(orders.where((order) => order['status'] == 'pending' || order['status'] == 'assigned').toList());
    } else {
      filteredOrders.assignAll(orders.where((order) => order['status'] == selectedStatus.value).toList());
    }
    filteredOrders.sort((a, b) {
      final aDate = DateTime.parse(a['createdAt'] ?? '');
      final bDate = DateTime.parse(b['createdAt'] ?? '');
      return bDate.compareTo(aDate);
    });
  }

  Future<bool> completeOrder(String orderId) async {
    try {
      isActionLoading.value = true;
      final response = await _orderService.updateVendorServices(orderId: orderId, status: "completed");
      if (response != null) {
        final index = orders.indexWhere((order) => order['_id'] == orderId);
        if (index != -1) {
          orders[index] = response;
          _filterOrders();
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

  Future<bool> collectCashPayment({required String paymentId, String? notes}) async {
    try {
      isActionLoading.value = true;
      await _orderService.collectCashPayment({'paymentId': paymentId, 'notes': notes, 'collectedBy': 'vendor'});
      return false;
    } catch (e) {
      toaster.error('Failed to complete order: $e');
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  void updateStatusFilter(String status) {
    orders.clear();
    filteredOrders.clear();
    selectedStatus.value = status;
    currentPage.value = 1;
    hasMore.value = true;
    getOrders();
  }

  void updateDateFilter(String filter, {DateTime? customStart, DateTime? customEnd}) {
    selectedDateFilter.value = filter;
    if (filter == 'custom') {
      startDate.value = customStart;
      endDate.value = customEnd;
    }
    currentPage.value = 1;
    hasMore.value = true;
    getOrders();
  }

  Future<void> updateDateRange(DateTime start, DateTime end) async {
    startDate.value = start;
    endDate.value = end;
    selectedDateFilter.value = 'custom';
    currentPage.value = 1;
    hasMore.value = true;
    await getOrders();
  }

  void clearFilters() {
    selectedStatus.value = 'all';
    selectedDateFilter.value = 'all';
    startDate.value = null;
    endDate.value = null;
    currentPage.value = 1;
    hasMore.value = true;
    getOrders();
  }

  Future<void> loadMoreOrders() async {
    if (!isLoading.value && hasMore.value) {
      await getOrders(loadMore: true);
    }
  }

  Future<void> refreshOrders() async {
    await getOrders(isRefresh: true);
  }

  bool get hasActiveFilters {
    return selectedStatus.value != 'all' || selectedDateFilter.value != 'all';
  }

  String getStatusDisplayText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
