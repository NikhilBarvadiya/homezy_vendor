import 'package:get/get.dart';
import 'package:homenest_vendor/utils/network/api_index.dart';
import 'package:homenest_vendor/utils/network/api_manager.dart';
import 'package:homenest_vendor/utils/toaster.dart';

class ChatService extends GetxService {
  Future<ChatService> init() async => this;

  Future<dynamic> sendMessage(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.sendMessage, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to send message');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> getChatHistory(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.chatHistory, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to load messages');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }

  Future<dynamic> markAsRead(Map<String, dynamic> request) async {
    try {
      final response = await ApiManager().call(APIIndex.markAsRead, request, ApiType.post);
      if (response.status != 200 || response.data == null) {
        toaster.warning(response.message ?? 'Failed to mark as read');
        return null;
      }
      return response.data;
    } catch (err) {
      toaster.error(err.toString());
      return null;
    }
  }
}
