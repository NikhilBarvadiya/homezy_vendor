import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/notifications/notifications_ctrl.dart';

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
        actions: [
          _notificationCtrl.unreadCount > 0
              ? IconButton(
                  icon: Badge(label: Text(_notificationCtrl.unreadCount.toString()), child: Icon(Icons.mark_email_read_outlined)),
                  onPressed: _notificationCtrl.markAllAsRead,
                  tooltip: 'Mark all as read',
                )
              : const SizedBox.shrink(),
        ],
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
                return _buildLoadingState();
              }
              if (_notificationCtrl.notifications.isEmpty) {
                return _buildEmptyState();
              }
              return RefreshIndicator(
                onRefresh: _notificationCtrl.refreshNotifications,
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

  Widget _buildNotificationCard(dynamic notification) {
    final isUnread = _notificationCtrl.isUnread(notification);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
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
              border: isUnread ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: .5) : null,
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
                      Text(
                        notification['title'] ?? 'Notification',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                          color: isUnread ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification['message'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isUnread ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _notificationCtrl.formatNotificationDate(notification['createdAt'] ?? ''),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                          ),
                          const Spacer(),
                          if (isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                'New',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 10),
                              ),
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
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (_notificationCtrl.notifications.isNotEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('No more notifications')),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text('Loading notifications...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            _notificationCtrl.searchQuery.isEmpty ? 'No Notifications' : 'No notifications found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            _notificationCtrl.searchQuery.isEmpty ? 'You don\'t have any notifications yet' : 'Try searching with different keywords',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          if (_notificationCtrl.searchQuery.isNotEmpty) ...[const SizedBox(height: 16), ElevatedButton(onPressed: _notificationCtrl.clearSearch, child: Text('Clear Search'))],
        ],
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
