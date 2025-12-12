import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homenest_vendor/views/dashboard/orders/ui/order_card.dart';
import 'package:intl/intl.dart';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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

  Widget _buildDateFilterChip() {
    return Obx(() {
      if (_orderController.startDate.value != null && _orderController.endDate.value != null) {
        return Chip(
          label: Text(
            '${DateFormat('MMM dd').format(_orderController.startDate.value!)} - ${DateFormat('MMM dd').format(_orderController.endDate.value!)}',
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          deleteIcon: Icon(Icons.close, size: 16),
          onDeleted: _orderController.clearFilters,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      }
      return const SizedBox.shrink();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100,
              floating: true,
              snap: true,
              pinned: true,
              titleSpacing: 10.0,
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Orders',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  _buildDateFilterChip(),
                  IconButton(
                    icon: Icon(Icons.filter_alt, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: _showFilterOptions,
                    tooltip: 'Filter',
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: innerBoxIsScrolled ? 4 : 0,
              surfaceTintColor: Theme.of(context).colorScheme.surface,
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
                    indicatorWeight: 2,
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    tabAlignment: TabAlignment.start,
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                    tabs: _orderController.tabs.map((e) {
                      return Tab(child: Text(e.capitalizeFirst!));
                    }).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Obx(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentIndex = _getIndexFromStatus(_orderController.selectedStatus.value);
            if (_tabController.index != currentIndex) {
              _tabController.animateTo(currentIndex);
            }
          });

          if (_orderController.filteredOrders.isNotEmpty && _orderController.isActionLoading.value) {
            return _buildFullScreenLoading();
          }

          return TabBarView(controller: _tabController, children: _orderController.tabs.map((e) => _buildOrdersSection(e)).toList());
        }),
      ),
    );
  }

  Widget _buildFullScreenLoading() {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary), strokeWidth: 3),
              const SizedBox(height: 16),
              Text(
                'Processing...',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersSection(String status) {
    final isLoading = _orderController.isLoading.value;
    if (isLoading && _orderController.filteredOrders.isEmpty) {
      return _buildShimmerLoading();
    }
    return RefreshIndicator(
      onRefresh: _orderController.refreshOrders,
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (_orderController.filteredOrders.isEmpty)
            SliverFillRemaining(child: _buildEmptyState(status))
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == _orderController.filteredOrders.length) {
                    return _buildLoadMoreIndicator();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(order: _orderController.filteredOrders[index], orderController: _orderController),
                  );
                }, childCount: _orderController.filteredOrders.length + 1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            children: [
              Container(
                height: 20,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(4)),
              ),
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_orderController.hasMore.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildEmptyState(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 100, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2)),
            const SizedBox(height: 24),
            Text(
              status == 'all' ? 'No Orders Found' : 'No ${status.capitalizeFirst} Orders',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              status == 'all' ? 'You don\'t have any orders yet. They\'ll appear here when you receive new orders.' : 'No orders found with "${status.capitalizeFirst}" status.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ),
            const SizedBox(height: 32),
            if (status == 'all')
              ElevatedButton(
                onPressed: _orderController.refreshOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Refresh', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
          ],
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Orders',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Date Range',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 12),
              Obx(() {
                final startDate = _orderController.startDate.value;
                final endDate = _orderController.endDate.value;
                return ElevatedButton(
                  onPressed: _showDateRangeDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startDate != null && endDate != null ? '${DateFormat('MMM dd, yyyy').format(startDate)} - ${DateFormat('MMM dd, yyyy').format(endDate)}' : 'Select Date Range',
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      Icon(Icons.calendar_today, size: 20, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _orderController.clearFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Clear All Filters', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Theme.of(context).colorScheme.primary, surface: Theme.of(context).colorScheme.surface),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _orderController.updateDateRange(picked.start, picked.end);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
