import 'package:get/get.dart';
import 'package:homezy_vendor/utils/service/notification_api_service.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class NotificationCtrl extends GetxController {
  final NotificationApiService _notificationService = Get.find<NotificationApiService>();
  final RxList<dynamic> notifications = <dynamic>[].obs;
  final RxBool isLoading = false.obs, isRefreshing = false.obs, hasMore = true.obs;
  final RxInt currentPage = 1.obs;
  final RxString searchQuery = ''.obs;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    getNotifications();
  }

  Future<void> getNotifications({bool loadMore = false, bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        isRefreshing.value = true;
        currentPage.value = 1;
        hasMore.value = true;
      } else if (loadMore) {
        if (!hasMore.value) return;
        currentPage.value++;
      } else {
        isLoading.value = true;
      }
      final response = await _notificationService.getMyNotifications(page: currentPage.value, limit: _limit, search: searchQuery.value);
      if (response != null && response['docs'] != null) {
        final newNotifications = response['docs'] as List<dynamic>;
        if (loadMore) {
          notifications.addAll(newNotifications);
        } else {
          notifications.assignAll(newNotifications);
        }
        hasMore.value = newNotifications.length == _limit;
      }
    } catch (e) {
      toaster.error('Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final response = await _notificationService.markAsRead(notificationId);
      if (response != null) {
        final index = notifications.indexWhere((n) => n['_id'] == notificationId);
        if (index != -1) {
          notifications[index] = {...notifications[index], 'isRead': true, 'readAt': DateTime.now().toIso8601String()};
          notifications.refresh();
        }
        return true;
      }
      return false;
    } catch (e) {
      toaster.error('Failed to mark notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final unreadNotifications = notifications.where((n) => n['isRead'] != true).toList();
      for (final notification in unreadNotifications) {
        await markAsRead(notification['_id']);
      }
      toaster.success('All notifications marked as read');
      return true;
    } catch (e) {
      toaster.error('Failed to mark all notifications as read: $e');
      return false;
    }
  }

  void searchNotifications(String query) {
    searchQuery.value = query;
    currentPage.value = 1;
    getNotifications();
  }

  void clearSearch() {
    searchQuery.value = '';
    currentPage.value = 1;
    getNotifications();
  }

  int get unreadCount {
    return notifications.where((n) => n['isRead'] != true).length;
  }

  Future<void> refreshNotifications() async {
    await getNotifications(isRefresh: true);
  }

  Future<void> loadMoreNotifications() async {
    if (!isLoading.value && hasMore.value) {
      await getNotifications(loadMore: true);
    }
  }

  bool isUnread(dynamic notification) {
    return notification['isRead'] != true;
  }

  String formatNotificationDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inHours < 1) return '${difference.inMinutes}m ago';
      if (difference.inDays < 1) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown time';
    }
  }
}
