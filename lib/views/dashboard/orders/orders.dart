import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/orders/orders_ctrl.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> with SingleTickerProviderStateMixin {
  final OrdersCtrl _orderController = Get.put(OrdersCtrl());
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _orderController.tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _orderController.loadMoreOrders();
    }
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging) {
      final status = _getStatusFromIndex(_tabController.index);
      _orderController.updateStatusFilter(status);
    }
  }

  String _getStatusFromIndex(int index) {
    return _orderController.tabs[index];
  }

  int _getIndexFromStatus(String status) {
    return _orderController.tabs.indexOf(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Orders', style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Obx(
            () => Badge(
              isLabelVisible: _orderController.startDate.value != null && _orderController.endDate.value != null,
              child: IconButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                ),
                icon: Icon(Icons.date_range_outlined),
                onPressed: _showDateRangeDialog,
                tooltip: 'Select Date Range',
              ),
            ),
          ),
          if (_orderController.startDate.value != null && _orderController.endDate.value != null)
            IconButton(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              ),
              icon: Icon(Icons.filter_alt_off_outlined),
              onPressed: _orderController.clearFilters,
              tooltip: 'Clear Date Filter',
            ),
          const SizedBox(width: 8.0),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: SizedBox(
            width: double.infinity,
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3,
              padding: const EdgeInsets.only(left: 10, right: 10),
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              tabs: [..._orderController.tabs.map((e) => Tab(text: e.capitalizeFirst))],
            ),
          ),
        ),
      ),
      body: Obx(() {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final currentIndex = _getIndexFromStatus(_orderController.selectedStatus.value);
          if (_tabController.index != currentIndex) {
            _tabController.animateTo(currentIndex);
          }
        });
        return TabBarView(controller: _tabController, children: [..._orderController.tabs.map((e) => _buildOrders(e))]);
      }),
    );
  }

  Future<void> _showDateRangeDialog() async {
    DateTimeRange? initialDateRange;
    if (_orderController.startDate.value != null && _orderController.endDate.value != null) {
      initialDateRange = DateTimeRange(start: _orderController.startDate.value!, end: _orderController.endDate.value!);
    }
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      currentDate: DateTime.now(),
      saveText: 'Select Range',
      helpText: 'Select Date Range',
      confirmText: 'Apply',
      cancelText: 'Cancel',
      fieldStartLabelText: 'Start date',
      fieldEndLabelText: 'End date',
    );
    if (picked != null) {
      _orderController.updateDateRange(picked.start, picked.end);
    }
  }

  Widget _buildOrders(String status) {
    final isRefreshing = _orderController.isRefreshing.value;
    final isLoading = _orderController.isLoading.value;
    if (isLoading && _orderController.filteredOrders.isEmpty) {
      return _buildLoadingState();
    }
    return RefreshIndicator(
      onRefresh: _orderController.refreshOrders,
      child: Stack(
        children: [
          if (_orderController.filteredOrders.isEmpty)
            _buildEmptyState(status)
          else
            ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _orderController.filteredOrders.length + 1,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == _orderController.filteredOrders.length) {
                  return _buildLoadMoreIndicator();
                }
                return _buildOrderCard(_orderController.filteredOrders[index]);
              },
            ),
          if (isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(backgroundColor: Theme.of(context).colorScheme.background, color: Theme.of(context).colorScheme.primary, minHeight: 3),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (_orderController.hasMore.value) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (_orderController.filteredOrders.isNotEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: Text('No more orders')),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final customer = order['customerId'] ?? {};
    final subcategory = order['subcategoryId'] ?? {};
    final payment = order['payment'] ?? {};
    final slot = order['slot'] ?? {};
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _orderController.getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: _orderController.getStatusColor(status), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    _orderController.getStatusDisplayText(status).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  'Order #${order['_id'].toString().substring(order['_id'].toString().length - 8).toUpperCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.home_repair_service, color: Theme.of(context).colorScheme.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subcategory['name'] ?? 'Service',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${subcategory['basePrice'] ?? '0'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow(icon: Icons.person_outline, title: 'Customer', value: customer['name'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(icon: Icons.phone_outlined, title: 'Contact', value: customer['mobileNo'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(icon: Icons.calendar_today_outlined, title: 'Date & Time', value: _formatDateTime(slot['startTime'])),
                const SizedBox(height: 8),
                _buildDetailRow(icon: Icons.location_on_outlined, title: 'Address', value: order['address']?['fullAddress'] ?? 'Address not provided', maxLines: 2),
                const SizedBox(height: 16),
                if (payment.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPaymentColor(payment['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getPaymentColor(payment['status']).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(_getPaymentIcon(payment['status']), size: 20, color: _getPaymentColor(payment['status'])),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment ${_getPaymentStatusText(payment['status'])}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: _getPaymentColor(payment['status'])),
                              ),
                              if (payment['amount'] != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  '₹${payment['amount']} • ${payment['mode'] ?? 'Online'}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (status == 'accepted') _buildAcceptedActions(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String value, int maxLines = 1}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcceptedActions(Map<String, dynamic> order) {
    return ElevatedButton(
      onPressed: _orderController.isActionLoading.value ? null : () => _showCompleteConfirmation(order),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48)),
      child: _orderController.isActionLoading.value
          ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline, size: 20), const SizedBox(width: 8), const Text('Mark as Completed')]),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Loading orders...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(status == 'all' ? 'No Orders' : 'No ${status.capitalizeFirst} Orders', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            status == 'all' ? 'You don\'t have any orders yet' : 'You don\'t have any ${status.capitalizeFirst} orders',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showCompleteConfirmation(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Order'),
        content: const Text('Mark this order as completed?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _orderController.completeOrder(order['_id']).then((success) {
                if (success) {
                  Get.snackbar('Success', 'Order marked as completed', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
                }
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(dynamic dateTime) {
    if (dateTime == null) return 'Not scheduled';
    try {
      final date = DateTime.parse(dateTime.toString());
      return '${_formatDate(date)} • ${_formatTime(date)}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getPaymentColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getPaymentIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentStatusText(String status) {
    switch (status) {
      case 'success':
        return 'Successful';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
