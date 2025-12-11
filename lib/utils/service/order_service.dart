import 'package:get/get.dart';
import 'package:homenest_vendor/utils/network/api_index.dart';
import 'package:homenest_vendor/utils/network/api_manager.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class OrderService extends GetxService {
  Future<OrderService> init() async => this;

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

  Future<dynamic> collectCashPayment(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.paymentCollectCash, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to complete order');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> getOrders(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.orderList, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to load orders');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }
}
