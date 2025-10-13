class ChatMessage {
  final String id;
  final String message;
  final String messageType;
  final String senderType;
  final bool isSentByMe;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;
  final String? mediaUrl;
  final String? fileName;

  ChatMessage({
    required this.id,
    required this.message,
    required this.messageType,
    required this.senderType,
    required this.isSentByMe,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.mediaUrl,
    this.fileName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      message: json['message'] ?? '',
      messageType: json['messageType'] ?? 'text',
      senderType: json['senderType'] ?? '',
      isSentByMe: json['isSentByMe'] ?? false,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      sender: json['sender'] is Map ? Map<String, dynamic>.from(json['sender']) : null,
      mediaUrl: json['mediaUrl'],
      fileName: json['fileName'],
    );
  }
}

class ChatList {
  final String id;
  final Map<String, dynamic> partner;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final String? orderId;
  final String? orderNumber;

  ChatList({required this.id, required this.partner, required this.lastMessage, required this.lastMessageAt, required this.unreadCount, this.orderId, this.orderNumber});

  factory ChatList.fromJson(Map<String, dynamic> json) {
    return ChatList(
      id: json['_id'] ?? '',
      partner: Map<String, dynamic>.from(json['partner'] ?? {}),
      lastMessage: json['lastMessage'] ?? '',
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toString()),
      unreadCount: json['unreadCount'] ?? 0,
      orderId: json['orderId'],
      orderNumber: json['orderNumber'],
    );
  }
}
