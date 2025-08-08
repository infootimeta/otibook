import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String nameSurname;
  final String qrCodeData;
  final DocumentReference parentRef;
  final List<DocumentReference> assignedTeacherRefs;
  final Timestamp createdAt;

  StudentModel({
    required this.id,
    required this.nameSurname,
    required this.qrCodeData,
    required this.parentRef,
    required this.assignedTeacherRefs,
    required this.createdAt,
  });

  // Firestore dökümanından StudentModel objesi oluşturmak için
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return StudentModel(
      id: doc.id,
      nameSurname: data['name_surname'] ?? '',
      qrCodeData: data['qr_code_data'] ?? '',
      parentRef: data['parent_ref'],
      assignedTeacherRefs: List<DocumentReference>.from(data['assigned_teacher_refs'] ?? []),
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }

  // StudentModel objesini Firestore'a yazmak için Map'e dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'name_surname': nameSurname,
      'qr_code_data': qrCodeData,
      'parent_ref': parentRef,
      'assigned_teacher_refs': assignedTeacherRefs,
      'created_at': createdAt,
    };
  }
}
