import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/utils/config/app_assets.dart';
import 'package:homezy_vendor/utils/helper.dart';
import 'package:homezy_vendor/utils/network/api_config.dart';
import 'package:homezy_vendor/views/dashboard/chat/chat_ctrl.dart';
import 'package:image_picker/image_picker.dart';

class Chat extends StatefulWidget {
  final String? chatId;
  final String partnerName;
  final String? partnerImage;

  const Chat({super.key, this.chatId, required this.partnerName, this.partnerImage});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatCtrl _chatController = Get.put(ChatCtrl());
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatHistory();
    });
  }

  void _loadChatHistory() {
    _chatController.getChatHistory().then((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    _chatController.sendMessage(message: message).then((success) {
      if (success) {
        _messageController.clear();
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (_chatController.isLoading.value && _chatController.messages.isEmpty) {
                  return _buildLoadingState();
                }
                return _buildMessagesList();
              }),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      titleSpacing: 0.0,
      shadowColor: Colors.black.withOpacity(0.1),
      title: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Obx(() {
                String image = _chatController.currentChatInfo["partner"]?["image"] ?? widget.partnerImage ?? "";
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundImage: image.isNotEmpty ? NetworkImage(APIConfig.resourceBaseURL + image) : null,
                  child: image.isEmpty ? Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20) : null,
                );
              }),
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(right: 2, bottom: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                  border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chatController.currentChatInfo["partner"]?["name"]?.toString().capitalizeFirst.toString() ?? widget.partnerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Online', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green)),
                ],
              );
            }),
          ),
        ],
      ),
      actions: [
        IconButton(
          style: ButtonStyle(
            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
          ),
          icon: Image.asset(AppAssets.callIcon, width: 24, color: Theme.of(context).colorScheme.primary),
          onPressed: () => helper.makePhoneCall("+919979066311"),
          tooltip: 'Call',
        ),
        SizedBox(width: 8.0),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 3),
          ),
          const SizedBox(height: 16),
          Text('Loading messages...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${widget.partnerName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _messageController.text = 'Hello!';
              _focusNode.requestFocus();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('Say Hello'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Obx(() {
      final messages = _chatController.messages;
      if (messages.isEmpty) {
        return _buildEmptyState();
      }
      return RefreshIndicator(
        onRefresh: () async => _loadChatHistory(),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.all(16),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return _buildMessageBubble(message, index);
          },
        ),
      );
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isMe = message['isSentByMe'] == true;
    final isText = message['messageType'] == 'text';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildPartnerAvatar(message),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: isText ? _buildTextMessage(message, isMe) : _buildMediaMessage(message, isMe),
                ),
                const SizedBox(height: 4),
                _buildMessageStatus(message, isMe),
              ],
            ),
          ),
          if (isMe) _buildSentStatus(message),
        ],
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isMe) {
    return Text(
      message['message'] ?? '',
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isMe ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface, fontSize: 15, height: 1.5),
    );
  }

  Widget _buildMediaMessage(Map<String, dynamic> message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message['mediaUrl'] != null)
          GestureDetector(
            onTap: () {
              dynamic uri = APIConfig.resourceBaseURL + message['mediaUrl'];
              Future.delayed(Duration.zero, () => _imageShow(uri));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                APIConfig.resourceBaseURL + message['mediaUrl'],
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 200,
                  height: 150,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(Icons.broken_image, color: Theme.of(context).colorScheme.error, size: 40),
                ),
              ),
            ),
          ),
        if (message['fileName'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.insert_drive_file, color: isMe ? Theme.of(context).colorScheme.surfaceVariant : Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message['fileName']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isMe ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
        if (message['message'] != null && message['message'].isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message['message']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isMe ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface, fontSize: 15),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageStatus(Map<String, dynamic> message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_formatTime(message['createdAt']), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSentStatus(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Icon(
          message['isRead'] == true ? Icons.done_all : Icons.done,
          key: ValueKey(message['isRead']),
          size: 16,
          color: message['isRead'] == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildPartnerAvatar(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        backgroundImage: message['sender']?['image'] != null ? NetworkImage(APIConfig.resourceBaseURL + message['sender']['image']) : null,
        child: message['sender']?['image'] == null ? Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary) : null,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(25)),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  prefixIcon: GestureDetector(
                    onTap: _showAttachmentOptions,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 16),
                      child: Image.asset(AppAssets.attachIcon, width: 24, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => IconButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                padding: WidgetStatePropertyAll(const EdgeInsets.all(8)),
              ),
              icon: _chatController.isSending.value
                  ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.onPrimary))
                  : Center(child: Image.asset(AppAssets.sendMsgIcon, width: 30, height: 30, color: Theme.of(context).colorScheme.onPrimary)),
              onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays > 0) {
        return '${difference.inDays}d';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m';
      } else {
        return 'Now';
      }
    } catch (e) {
      return '';
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.only(left: 15, right: 15),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              leading: Icon(Icons.photo, color: Theme.of(context).colorScheme.primary),
              title: Text('Gallery', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () async {
                Get.back();
                _chatController.pickAndSendMedia(ImageSource.gallery);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 15, right: 15),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              title: Text('Camera', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () async {
                Get.back();
                _chatController.pickAndSendMedia(ImageSource.camera);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.only(left: 15, right: 15),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
              leading: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
              title: Text('Document', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                _chatController.pickAndSendDocument();
              },
            ),
          ],
        ),
      ),
    );
  }

  _imageShow(String uri) {
    return showDialog(
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(2),
          title: SizedBox(
            height: Get.height / 2,
            width: Get.size.width,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: InteractiveViewer(
                child: Image.network(
                  uri,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? value) {
                    if (value == null) {
                      return child;
                    }
                    return Center(child: CircularProgressIndicator(value: value.expectedTotalBytes != null ? value.cumulativeBytesLoaded / value.expectedTotalBytes! : null));
                  },
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
            ),
          ),
        );
      },
      context: context,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
