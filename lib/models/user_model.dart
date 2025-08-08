import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nameSurname;
  final String role;
  final Timestamp createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.nameSurname,
    required this.role,
    required this.createdAt,
  });

  // Firestore dökümanından UserModel objesi oluşturmak için factory constructor
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nameSurname: data['name_surname'] ?? '',
      role: data['role'] ?? 'parent', // Varsayılan rol
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  // UserModel objesini Firestore'a yazmak için Map'e dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name_surname': nameSurname,
      'role': role,
      'created_at': createdAt,
    };
  }
}
