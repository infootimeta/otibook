// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nameSurname;
  final String role;

  UserModel({
    required this.uid,
    required this.nameSurname,
    required this.role,
  });

  factory UserModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return UserModel(
      uid: doc.id,
      nameSurname: (data['nameSurname'] ?? '') as String,
      role: (data['role'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameSurname': nameSurname,
      'role': role,
    };
  }
}
