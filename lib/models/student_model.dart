// lib/models/student_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String nameSurname;
  final List<DocumentReference<Map<String, dynamic>>> assignedTeacherRefs;

  StudentModel({
    required this.id,
    required this.nameSurname,
    required this.assignedTeacherRefs,
  });

  factory StudentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final rawRefs = (data['assignedTeacherRefs'] as List?) ?? [];
    final refs = rawRefs
        .whereType<DocumentReference>()
        .map((r) => r as DocumentReference<Map<String, dynamic>>)
        .toList();

    return StudentModel(
      id: doc.id,
      nameSurname: (data['nameSurname'] ?? '') as String,
      assignedTeacherRefs: refs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameSurname': nameSurname,
      'assignedTeacherRefs': assignedTeacherRefs,
    };
  }

  static fromJson(Map<String, dynamic> data) {}
}
