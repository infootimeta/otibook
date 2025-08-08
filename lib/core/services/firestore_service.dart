import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/models/student_model.dart';
import 'package:otibook/models/session_note_model.dart';
import 'package:otibook/models/user_model.dart'; 
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // --- Mevcut Fonksiyonlar ---
  Stream<List<StudentModel>> getAssignedStudents(String teacherId) {
    final teacherRef = _db.collection('users').doc(teacherId);
    return _db.collection('students').where('assigned_teacher_refs', arrayContains: teacherRef).snapshots().map((snapshot) => snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList());
  }
  Future<StudentModel?> getStudentDetails(String studentId) async {
    final doc = await _db.collection('students').doc(studentId).get();
    return doc.exists ? StudentModel.fromFirestore(doc) : null;
  }
  Stream<List<SessionNoteModel>> getSessionNotes(String studentId) {
    final studentRef = _db.collection('students').doc(studentId);
    return _db.collection('session_notes').where('student_ref', isEqualTo: studentRef).orderBy('created_at', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => SessionNoteModel.fromFirestore(doc)).toList());
  }
  Future<void> addSessionNote({required String studentId, required String teacherId, String? noteText, String? mediaUrl, String? audioUrl}) async {
     final studentRef = _db.collection('students').doc(studentId);
     final teacherRef = _db.collection('users').doc(teacherId);
     await _db.collection('session_notes').add({'created_at': Timestamp.now(), 'student_ref': studentRef, 'teacher_ref': teacherRef, 'note_text': noteText, 'media_url': mediaUrl, 'audio_url': audioUrl});
  }
  Future<StudentModel?> getStudentByQrCode(String qrCodeData) async {
    final querySnapshot = await _db.collection('students').where('qr_code_data', isEqualTo: qrCodeData).limit(1).get();
    return querySnapshot.docs.isNotEmpty ? StudentModel.fromFirestore(querySnapshot.docs.first) : null;
  }
  Future<DocumentReference?> findParentByEmail(String email) async {
    final query = await _db.collection('users').where('email', isEqualTo: email).where('role', isEqualTo: 'parent').limit(1).get();
    return query.docs.isNotEmpty ? query.docs.first.reference : null;
  }
  Future<void> createStudent({required String nameSurname, required DocumentReference parentRef}) async {
    final qrCodeData = _uuid.v4();
    await _db.collection('students').add({'name_surname': nameSurname, 'qr_code_data': qrCodeData, 'parent_ref': parentRef, 'assigned_teacher_refs': [], 'created_at': FieldValue.serverTimestamp()});
  }

  // --- YENİ FONKSİYONLAR ---
  
  // Tüm öğrencileri getir
  Future<List<StudentModel>> getStudents() async {
    final snapshot = await _db.collection('students').orderBy('name_surname').get();
    return snapshot.docs.map((doc) => StudentModel.fromFirestore(doc)).toList();
  }
  
  // Tüm öğretmenleri getir
  Future<List<UserModel>> getTeachers() async {
    final snapshot = await _db.collection('users').where('role', isEqualTo: 'teacher').orderBy('name_surname').get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }
  
  // Bir öğrenciye öğretmen ata/güncelle
  Future<void> assignTeachersToStudent(String studentId, List<DocumentReference> teacherRefs) async {
    try {
      await _db.collection('students').doc(studentId).update({
        'assigned_teacher_refs': teacherRefs,
      });
    } catch (e) {
      //print('Error assigning teachers: $e');
      throw Exception('Öğretmen ataması sırasında bir hata oluştu.');
    }
  }
}
