import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  final String displayName;
  final String email;
  final String role;
  final DateTime? createdTime;
  final String? photoUrl;
  final String phoneNumber;

  UserData({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    this.createdTime,
    this.photoUrl,
    required this.phoneNumber,
  });

  factory UserData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      uid: doc.id,
      displayName: data['display_name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      createdTime: data['created_time'] != null
          ? (data['created_time'] as Timestamp).toDate()
          : null,
      photoUrl: data['photo_url'],
      phoneNumber: data['phone_number'] ?? '',
    );
  }
}

class ChatData {
  final String groupChatId;
  final String lastMessage;
  final String lastMessageSentBy;
  final DateTime? lastMessageTime;
  final String userA;
  final String userB;
  final List<String> users;

  ChatData({
    required this.groupChatId,
    required this.lastMessage,
    required this.lastMessageSentBy,
    this.lastMessageTime,
    required this.userA,
    required this.userB,
    required this.users,
  });

  factory ChatData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatData(
      groupChatId: data['group_chat_id'] ?? '',
      lastMessage: data['last_message'] ?? '',
      lastMessageSentBy: data['last_message_sent_by'] ?? '',
      lastMessageTime: data['last_message_time'] != null
          ? (data['last_message_time'] as Timestamp).toDate()
          : null,
      userA: data['user_a'] ?? '',
      userB: data['user_b'] ?? '',
      users: List<String>.from(data['users'] ?? []),
    );
  }
}

class ChatMessage {
  final String chatId;
  final String text;
  final String? imageUrl;
  final DateTime? timestamp;
  final String userId;

  ChatMessage({
    required this.chatId,
    required this.text,
    this.imageUrl,
    this.timestamp,
    required this.userId,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      chatId: data['chat'] ?? '',
      text: data['text'] ?? '',
      imageUrl: data['image'],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
      userId: data['user'] ?? '',
    );
  }
}
