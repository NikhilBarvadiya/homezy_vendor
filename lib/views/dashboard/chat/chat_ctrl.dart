import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:homenest_vendor/utils/config/session.dart';
import 'package:homenest_vendor/utils/helper.dart';
import 'package:homenest_vendor/utils/service/chat_service.dart';
import 'package:homenest_vendor/utils/storage.dart';
import 'package:homenest_vendor/utils/toaster.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ChatCtrl extends GetxController {
  final ChatService _chatService = Get.find<ChatService>();

  final RxList<dynamic> messages = <dynamic>[].obs;
  final RxMap<String, dynamic> currentChatInfo = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs, isSending = false.obs, hasMoreMessages = true.obs;
  final RxInt currentPage = 1.obs;

  Future<void> pickAndSendMedia(ImageSource source) async {
    try {
      final pickedFile = await helper.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileName = pickedFile.path.split('/').last;
        final fileSize = await file.length();
        final mimeType = lookupMimeType(pickedFile.path) ?? 'image/jpeg';
        await sendMessage(message: "image upload", messageType: 'image', fileName: fileName, fileSize: fileSize, fileMimeType: mimeType);
      }
    } catch (e) {
      toaster.error('Error picking image: $e');
    }
  }

  Future<void> pickAndSendDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'txt']);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;
        final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
        await sendMessage(message: "file upload", messageType: 'file', fileName: fileName, fileSize: fileSize, fileMimeType: mimeType);
      }
    } catch (e) {
      toaster.error('Error picking document: $e');
    }
  }

  Future<bool> sendMessage({required String message, String messageType = 'text', String? fileName, int? fileSize, String? fileMimeType}) async {
    try {
      isSending.value = true;
      final request = {'message': message, 'messageType': messageType, 'fileName': fileName ?? "", 'fileSize': fileSize ?? 0, 'fileMimeType': fileMimeType ?? ""};
      final response = await _chatService.sendMessage(request);
      if (response != null) {
        final newMessage = response['message'];
        messages.add(newMessage);
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

  onNewDataUpdate(dynamic message) async {
    messages.add(Map<String, dynamic>.from(message));
  }

  Future<void> getChatHistory({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        hasMoreMessages.value = true;
        messages.clear();
      }
      dynamic userData = await read(AppSession.userData);
      final request = {'page': currentPage.value, 'limit': 20, 'vendorId': userData["_id"]};
      final response = await _chatService.getChatHistory(request);
      if (response != null) {
        if (response['chatInfo'] != null) {
          currentChatInfo.value = response['chatInfo'];
        }
        final List<dynamic> messageList = response['messages'];
        if (loadMore) {
          messages.insertAll(0, messageList);
        } else {
          messages.assignAll(messageList);
        }
        final pagination = response['pagination'];
        hasMoreMessages.value = currentPage.value < (int.tryParse(pagination['totalPages'].toString()) ?? 0);
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

  Future<void> markAsRead(String chatId, {String? messageId}) async {
    try {
      final request = {'chatId': chatId, 'messageId': messageId};
      await _chatService.markAsRead(request);
    } catch (e) {
      toaster.error('Error marking as read: $e');
    }
  }

  void loadMoreMessages() {
    if (hasMoreMessages.value && !isLoading.value) {
      getChatHistory(loadMore: true);
    }
  }
}
