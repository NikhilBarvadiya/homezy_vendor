import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homezy_vendor/views/dashboard/chat/chat_ctrl.dart';

class Chat extends StatefulWidget {
  final String? chatId;
  final String? vendorId;
  final String? orderId;
  final String partnerName;
  final String? partnerImage;

  const Chat({super.key, this.chatId, this.vendorId, this.orderId, required this.partnerName, this.partnerImage});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final ChatCtrl _chatController = Get.find<ChatCtrl>();
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
    _chatController.getChatHistory(vendorId: widget.vendorId, orderId: widget.orderId).then((_) {
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
      body: Column(
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
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
            child: widget.partnerImage != null
                ? ClipOval(
                    child: Image.network(widget.partnerImage!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context)),
                  )
                : _buildDefaultAvatar(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.partnerName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Obx(() {
                  return Text('Online', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green));
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.call, color: Theme.of(context).colorScheme.primary),
          onPressed: _makeCall,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2),
          const SizedBox(height: 16),
          Text('Loading messages...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No messages yet', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${widget.partnerName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, int index) {
    final isMe = message['isSentByMe'] == true;
    final isText = message['messageType'] == 'text';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildPartnerAvatar(message),
          Expanded(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message Bubble
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: isText ? _buildTextMessage(message, isMe) : _buildMediaMessage(message, isMe),
                ),
                const SizedBox(height: 4),
                // Time and Status
                _buildMessageStatus(message, isMe),
              ],
            ),
          ),
          if (isMe) _buildSentStatus(message),
        ],
      ),
    );
  }

  Widget _buildPartnerAvatar(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        backgroundImage: message['sender']?['image'] != null ? NetworkImage(message['sender']['image']) : null,
        child: message['sender']?['image'] == null ? Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.primary) : null,
      ),
    );
  }

  Widget _buildTextMessage(Map<String, dynamic> message, bool isMe) {
    return Text(message['message'] ?? '', style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface, fontSize: 14, height: 1.4));
  }

  Widget _buildMediaMessage(Map<String, dynamic> message, bool isMe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message['mediaUrl'] != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message['mediaUrl']!,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 150,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Center(
                    child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 200,
                height: 150,
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        if (message['fileName'] != null) ...[
          const SizedBox(height: 8),
          Text(
            message['fileName']!,
            style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
        if (message['message'] != null && message['message'].isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(message['message']!, style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurface, fontSize: 14)),
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
          Text(_formatTime(message['createdAt']), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10)),
          if (isMe) ...[
            const SizedBox(width: 4),
            Icon(
              message['isRead'] == true ? Icons.done_all : Icons.done,
              size: 12,
              color: message['isRead'] == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentStatus(Map<String, dynamic> message) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: Icon(
        message['isRead'] == true ? Icons.done_all : Icons.done,
        size: 16,
        color: message['isRead'] == true ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          // Attachment Button
          IconButton(
            icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
            onPressed: _showAttachmentOptions,
          ),
          // Message Input
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 100),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // Send Button
          Obx(() {
            return IconButton(
              icon: _chatController.isSending.value
                  ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
                  : Icon(Icons.send, color: _messageController.text.trim().isEmpty ? Theme.of(context).colorScheme.onSurfaceVariant : Theme.of(context).colorScheme.primary),
              onPressed: _messageController.text.trim().isEmpty ? null : _sendMessage,
            );
          }),
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

  void _makeCall() {
    Get.snackbar(
      'Call',
      'Calling ${widget.partnerName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Theme.of(context).colorScheme.surface,
      colorText: Theme.of(context).colorScheme.onSurface,
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
              title: Text('Chat Info', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                _showChatInfo();
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Theme.of(context).colorScheme.error),
              title: Text('Block User', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                _blockUser();
              },
            ),
            ListTile(
              leading: Icon(Icons.report, color: Theme.of(context).colorScheme.error),
              title: Text('Report', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                _reportChat();
              },
            ),
          ],
        ),
      ),
    );
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
              leading: Icon(Icons.photo, color: Theme.of(context).colorScheme.primary),
              title: Text('Gallery', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                // Implement gallery picker
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary),
              title: Text('Camera', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                // Implement camera
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
              title: Text('Document', style: Theme.of(context).textTheme.bodyMedium),
              onTap: () {
                Get.back();
                // Implement document picker
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChatInfo() {
    // Implement chat info
  }

  void _blockUser() {
    // Implement block user
  }

  void _reportChat() {
    // Implement report
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
