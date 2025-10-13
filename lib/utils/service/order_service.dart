import 'package:get/get.dart';
import 'package:homezy_vendor/utils/network/api_index.dart';
import 'package:homezy_vendor/utils/network/api_manager.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class OrderService extends GetxService {
  Future<OrderService> init() async => this;

  Future<dynamic> acceptOrder(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.acceptOrder, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to accept order');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> rejectOrder(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.rejectOrder, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to reject order');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> completeOrder(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.completeOrder, request, ApiType.post);
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
