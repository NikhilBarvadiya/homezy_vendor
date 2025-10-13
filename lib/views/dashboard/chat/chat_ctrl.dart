import 'package:get/get.dart';
import 'package:homezy_vendor/utils/config/session.dart';
import 'package:homezy_vendor/utils/service/chat_service.dart';
import 'package:homezy_vendor/utils/storage.dart';
import 'package:homezy_vendor/utils/toaster.dart';

class ChatCtrl extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();

  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxList<dynamic> chatList = <dynamic>[].obs;
  final RxMap<String, dynamic> currentChatInfo = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs, isSending = false.obs, hasMoreMessages = true.obs;
  final RxInt currentPage = 1.obs;

  @override
  void onInit() {
    super.onInit();
    initializeSocket();
  }

  void initializeSocket() {
    // Socket.io implementation for real-time messages
    // You can use socket_io_client package
  }

  Future<bool> sendMessage({
    required String message,
    String messageType = 'text',
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    String? fileMimeType,
    String? thumbnailUrl,
    String? orderId,
    String? orderUpdate,
  }) async {
    try {
      isSending.value = true;
      final request = {
        'message': message,
        'messageType': messageType,
        'mediaUrl': mediaUrl,
        'fileName': fileName,
        'fileSize': fileSize,
        'fileMimeType': fileMimeType,
        'thumbnailUrl': thumbnailUrl,
        'orderId': orderId,
        'orderUpdate': orderUpdate,
      };
      final response = await _chatService.sendMessage(request);
      if (response != null) {
        final newMessage = response['message'];
        messages.insert(0, newMessage);
        updateChatListLastMessage(newMessage);
        return true;
      }
      return false;
    } catch (e) {
      toaster.error('Failed to send message: $e');
      return false;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> getChatHistory({String? orderId, bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreMessages.value = true;
        messages.clear();
      }
      dynamic userData = await read(AppSession.userData);
      final request = {'page': currentPage.value, 'limit': 20, 'orderId': orderId, 'vendorId': userData["_id"]};
      final response = await _chatService.getChatHistory(request);
      if (response != null) {
        if (response['chatInfo'] != null) {
          currentChatInfo.value = response['chatInfo'];
        }
        final List<dynamic> messageList = response['messages'];
        if (loadMore) {
          messages.addAll(messageList);
        } else {
          messages.assignAll(messageList);
        }
        final pagination = response['pagination'];
        hasMoreMessages.value = currentPage.value < pagination['totalPages'];
        if (loadMore) {
          currentPage.value++;
        }
      }
    } catch (e) {
      toaster.error('Failed to load messages: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getChatList({String? search}) async {
    try {
      isLoading.value = true;
      final request = {'page': 1, 'limit': 50, 'search': search};
      final response = await _chatService.getChatList(request);
      if (response != null) {
        final List<dynamic> chats = response['chats'];
        chatList.assignAll(chats);
      }
    } catch (e) {
      toaster.error('Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String chatId, {String? messageId}) async {
    try {
      final request = {'chatId': chatId, 'messageId': messageId};
      await _chatService.markAsRead(request);
    } catch (e) {
      toaster.error('Error marking as read: $e');
    }
  }

  void updateChatListLastMessage(Map<String, dynamic> message) {
    final chatIndex = chatList.indexWhere((chat) => chat['_id'] == currentChatInfo['_id']);
    if (chatIndex != -1) {
      final updatedChat = Map<String, dynamic>.from(chatList[chatIndex]);
      updatedChat['lastMessage'] = message['message'];
      updatedChat['lastMessageAt'] = message['createdAt'];
      chatList[chatIndex] = updatedChat;
    }
  }

  void loadMoreMessages() {
    if (hasMoreMessages.value && !isLoading.value) {
      getChatHistory(loadMore: true);
    }
  }
}
