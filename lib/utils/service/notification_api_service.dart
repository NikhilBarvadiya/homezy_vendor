import 'package:get/get.dart';
import 'package:homenest_vendor/utils/network/api_index.dart';
import 'package:homenest_vendor/utils/network/api_manager.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class NotificationApiService extends GetxService {
  Future<NotificationApiService> init() async => this;

  Future<dynamic> getMyNotifications({int page = 1, int limit = 10, String search = ''}) async {
    try {
      final response = await ApiManager().call(APIIndex.myNotifications, {'page': page, 'limit': limit, 'search': search}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      rethrow;
    }
  }

  Future<dynamic> markAsRead(String notificationId) async {
    try {
      final response = await ApiManager().call(APIIndex.markReadNotifications, {'notificationId': notificationId}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      rethrow;
    }
  }
}
