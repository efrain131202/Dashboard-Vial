import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String uid;
  final String displayName;
  final String email;
  final String role;
  final DateTime createdTime;
  final String? photoUrl;

  UserData({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.role,
    required this.createdTime,
    this.photoUrl,
  });

  factory UserData.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserData(
      uid: doc.id,
      displayName: data['display_name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      createdTime: (data['created_time'] as Timestamp).toDate(),
      photoUrl: data['photo_url'],
    );
  }
}
