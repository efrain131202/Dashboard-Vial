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
