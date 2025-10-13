import 'package:get/get.dart';
import 'package:homezy_vendor/utils/network/api_index.dart';
import 'package:homezy_vendor/utils/network/api_manager.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class BookingsService extends GetxService {
  Future<BookingsService> init() async => this;

  Future<dynamic> getServicesList({int page = 1, int limit = 10, String search = ''}) async {
    try {
      final response = await ApiManager().call(APIIndex.servicesList, {'page': page, 'limit': limit, 'search': search}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getAvailableBookings() async {
    try {
      final response = await ApiManager().call(APIIndex.getAvailableBookings, {}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> updateVendorServices({String? orderId, String? status}) async {
    try {
      final response = await ApiManager().call(APIIndex.updateVendorServices, {"orderId": orderId, "status": status}, ApiType.post);
      if (response.status != 200 || response.data == null || response.data == 0) {
        toaster.warning(response.message ?? 'Something went wrong');
        return;
      }
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
