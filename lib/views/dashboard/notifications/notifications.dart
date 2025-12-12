import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/views/dashboard/notifications/notifications_ctrl.dart';
import 'package:shimmer/shimmer.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final NotificationCtrl _notificationCtrl = Get.put(NotificationCtrl());
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _notificationCtrl.loadMoreNotifications();
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      _notificationCtrl.clearSearch();
    }
  }

  void _performSearch() {
    _notificationCtrl.searchNotifications(_searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  suffixIcon: _notificationCtrl.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          onPressed: () {
                            _searchController.clear();
                            _notificationCtrl.clearSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onSubmitted: (_) => _performSearch(),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_notificationCtrl.isLoading.value && _notificationCtrl.notifications.isEmpty) {
                return _buildShimmerLoading();
              }
              if (_notificationCtrl.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: _notificationCtrl.refreshNotifications,
                color: Theme.of(context).colorScheme.primary,
                child: ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _notificationCtrl.notifications.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    if (index == _notificationCtrl.notifications.length) {
                      return _buildLoadMoreIndicator();
                    }
                    return _buildNotificationCard(_notificationCtrl.notifications[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: [const SizedBox(height: 8), for (int i = 0; i < 5; i++) _buildShimmerNotificationCard()]),
    );
  }

  Widget _buildShimmerNotificationCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          period: const Duration(milliseconds: 1500),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 200,
                      height: 12,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 80,
                          height: 10,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                        ),
                        Container(
                          width: 40,
                          height: 20,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic notification) {
    final isUnread = _notificationCtrl.isUnread(notification);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            if (isUnread) {
              await _notificationCtrl.markAsRead(notification['_id']);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1),
              boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.outlineVariant, blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isUnread ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.notifications_none, size: 20, color: isUnread ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification['title'] ?? 'Notification',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500, color: isUnread ? Colors.black87 : Colors.grey[700]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                'New',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.w600, fontSize: 10),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              notification['message'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                height: 1.4,
                                color: isUnread ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _notificationCtrl.formatNotificationDate(notification['createdAt'] ?? ''),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (_notificationCtrl.hasMore.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Colors.grey[300], shape: BoxShape.circle),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 120,
                  height: 12,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
        );
      } else if (_notificationCtrl.notifications.isNotEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text('No more notifications', style: TextStyle(color: Colors.grey)),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              _notificationCtrl.searchQuery.isEmpty ? 'No Notifications' : 'No notifications found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              _notificationCtrl.searchQuery.isEmpty ? 'You don\'t have any notifications yet' : 'Try searching with different keywords',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
            if (_notificationCtrl.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _notificationCtrl.clearSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
