import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/orders/orders_ctrl.dart';

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
          Obx(() {
            if (_orderController.startDate.value != null && _orderController.endDate.value != null) {
              return IconButton(
                style: ButtonStyle(
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
                ),
                icon: Icon(Icons.filter_alt_off_outlined),
                onPressed: _orderController.clearFilters,
                tooltip: 'Clear Date Filter',
              );
            }
            return SizedBox.shrink();
          }),
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
        if (_orderController.filteredOrders.isNotEmpty && _orderController.isActionLoading.value) {
          return _buildFullScreenLoading('Completed Booking...', Icons.star_outlined);
        }
        return TabBarView(controller: _tabController, children: [..._orderController.tabs.map((e) => _buildOrders(e))]);
      }),
    );
  }

  Widget _buildFullScreenLoading(String message, IconData icon) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), strokeWidth: 3),
                  ),
                  Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('Please wait...', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
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
                return OrderCard(order: _orderController.filteredOrders[index], orderController: _orderController);
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

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class OrderCard extends StatefulWidget {
  final Map<String, dynamic> order;
  final OrdersCtrl orderController;

  const OrderCard({super.key, required this.order, required this.orderController});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final status = order['status'] ?? 'pending';
    final customer = order['customer'] ?? {};
    final service = order['service'] ?? {};
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
              color: widget.orderController.getStatusColor(status).withOpacity(0.1),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: widget.orderController.getStatusColor(status), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    widget.orderController.getStatusDisplayText(status).toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                ),
                const Spacer(),
                Text(
                  'Order #${order['orderNumber'] ?? 'N/A'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpand,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
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
                            service['name'] ?? 'Service',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${order['totalPrice'] ?? '0'}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuickInfoRow(context, customer, slot),
                if (_isExpanded) ...[const SizedBox(height: 16), _buildExpandableSection(context, order)],
                const SizedBox(height: 16),
                _buildActionButtons(order),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(BuildContext context, Map<String, dynamic> customer, Map<String, dynamic> slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(customer['name'] ?? 'N/A', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Time', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(slot['displayTime'] ?? 'Not scheduled', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(BuildContext context, Map<String, dynamic> order) {
    final customer = order['customer'] ?? {};
    final service = order['service'] ?? {};
    final payment = order['payment'] ?? {};
    final slot = order['slot'] ?? {};
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildDetailItem(context, icon: Icons.person_outline, label: 'Customer Name', value: customer['name'] ?? 'N/A'),
          _buildDetailItem(context, icon: Icons.phone_iphone, label: 'Mobile Number', value: customer['mobileNo'] ?? 'N/A', isPhone: true),
          _buildDetailItem(context, icon: Icons.email_outlined, label: 'Email', value: customer['email'] ?? 'N/A'),
          _buildDetailItem(context, icon: Icons.calendar_today, label: 'Service Date', value: slot['date'] != null ? _formatServiceDate(slot['date']) : 'Not scheduled'),
          _buildDetailItem(context, icon: Icons.access_time, label: 'Time Slot', value: slot['displayTime'] ?? 'Not scheduled'),
          _buildDetailItem(context, icon: Icons.engineering, label: 'Service Type', value: service['name'] ?? 'Service'),
          _buildDetailItem(context, icon: Icons.category, label: 'Category', value: service['category'] ?? 'N/A'),
          if (payment.isNotEmpty) ...[const SizedBox(height: 8), _buildPaymentStatus(context, payment: payment)],
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, {required IconData icon, required String label, required String value, bool isPhone = false}) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 2),
                if (isPhone)
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary),
                  )
                else
                  Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatus(BuildContext context, {required Map<String, dynamic> payment}) {
    final status = payment['status'] ?? 'pending';
    final statusColor = _getPaymentColor(status);
    final statusText = _getPaymentStatusText(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(_getPaymentIcon(status), size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment $statusText',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: statusColor),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${payment['amount'] ?? '0'} • ${payment['mode'] == 'online' ? 'Online' : 'Cash'}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              status.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: statusColor, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final payment = order['payment'] ?? {};
    if (status == 'accepted') {
      return Column(
        children: [
          if (payment['mode'] == 'cash' && payment['status'] == 'pending') ...[
            ElevatedButton(
              onPressed: () => _showCollectCashDialog(order),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.money, size: 20), const SizedBox(width: 8), const Text('Collect Cash Payment')]),
            ),
            const SizedBox(height: 12),
          ],
          ElevatedButton(
            onPressed: () => _showCompleteConfirmation(order),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.check_circle_outline, size: 20), const SizedBox(width: 8), const Text('Mark as Completed')]),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  void _showCollectCashDialog(Map<String, dynamic> order) {
    final payment = order['payment'] ?? {};
    final TextEditingController notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Collect Cash Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ₹${payment['amount'] ?? '0'}'),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes (Optional)', border: OutlineInputBorder()),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              widget.orderController.collectCashPayment(paymentId: payment['_id'], notes: notesController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Collect Cash'),
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
          TextButton(onPressed: () => Get.close(1), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.close(1);
              widget.orderController.completeOrder(order['_id']);
            },
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.green), padding: WidgetStatePropertyAll(EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 5))),
            child: const Text('Complete', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  String _formatServiceDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Invalid date';
    }
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
}
