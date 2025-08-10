// lib/core/services/firestore_service.dart
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/models/student_model.dart';
import 'package:otibook/models/session_note_model.dart';
import 'package:otibook/models/user_model.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? instance})
      : _db = instance ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // -----------------------------
  // Collection refs (withConverter)
  // -----------------------------
  CollectionReference<StudentModel> get _studentsCol =>
      _db.collection('students').withConverter<StudentModel>(
        fromFirestore: (snap, _) => StudentModel.fromDoc(snap),
        toFirestore: (student, _) => student.toMap(),
      );

  CollectionReference<UserModel> get _usersCol =>
      _db.collection('users').withConverter<UserModel>(
        fromFirestore: (snap, _) => UserModel.fromDoc(snap),
        toFirestore: (user, _) => user.toMap(),
      );

  CollectionReference<SessionNoteModel> _sessionNotesCol(String studentId) =>
      _db.collection('students/$studentId/sessionNotes')
          .withConverter<SessionNoteModel>(
        fromFirestore: (snap, _) => SessionNoteModel.fromFirestore(snap),
        toFirestore: (note, _) => note.toMap(),
      );

  // -----------------------------
  // Error helper
  // -----------------------------
  String getFirestoreErrorMessage(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case 'permission-denied':
          return 'Yetki hatası. Bu işlem için izniniz yok.';
        case 'unavailable':
          return 'Hizmet geçici olarak kullanılamıyor. Lütfen tekrar deneyin.';
        case 'not-found':
          return 'Kayıt bulunamadı.';
        case 'already-exists':
          return 'Kayıt zaten mevcut.';
        case 'deadline-exceeded':
          return 'İstek zaman aşımına uğradı.';
        case 'cancelled':
          return 'İşlem iptal edildi.';
        case 'aborted':
          return 'İşlem iptal edildi (aborted).';
        case 'resource-exhausted':
          return 'Kotaya ulaşıldı. Daha sonra tekrar deneyin.';
        default:
          return e.message ?? 'Bilinmeyen bir Firestore hatası oluştu.';
      }
    }
    return 'Beklenmeyen bir hata oluştu.';
  }

  // -----------------------------
  // Students - Read (list/detail/stream) + paging
  // -----------------------------
  Future<List<StudentModel>> getStudents({int? limit, DocumentSnapshot? startAfter}) async {
    try {
      Query<StudentModel> q = _studentsCol.orderBy('createdAt', descending: true);
      if (limit != null) q = q.limit(limit);
      if (startAfter != null) q = q.startAfterDocument(startAfter);
      final snap = await q.get();
      return snap.docs.map((d) => d.data()).toList();
    } on FirebaseException catch (e, st) {
      log('getStudents error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('getStudents unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<StudentModel>> streamStudents({int? limit}) {
    Query<StudentModel> q = _studentsCol.orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<StudentModel?> getStudentDetails(String studentId) async {
    try {
      final doc = await _studentsCol.doc(studentId).get();
      return doc.exists ? doc.data() : null;
    } on FirebaseException catch (e, st) {
      log('getStudentDetails error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('getStudentDetails unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  // -----------------------------
  // Students - Create/Update/Delete
  // -----------------------------
  Future<void> addStudent(StudentModel student) async {
    try {
      final ref = _studentsCol.doc(student.id); // id alanın farklıysa uyarlayın
      await ref.set(student);
    } on FirebaseException catch (e, st) {
      log('addStudent error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('addStudent unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateStudent(String studentId, Map<String, Object?> data, {bool merge = true}) async {
    try {
      if (merge) {
        await _studentsCol.doc(studentId).update(data);
      } else {
        await _studentsCol.doc(studentId).update(data);
      }
    } on FirebaseException catch (e, st) {
      log('updateStudent error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('updateStudent unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteStudent(String studentId) async {
    try {
      await _studentsCol.doc(studentId).delete();
    } on FirebaseException catch (e, st) {
      log('deleteStudent error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('deleteStudent unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  // -----------------------------
  // Session Notes
  // -----------------------------
  Future<List<SessionNoteModel>> getSessionNotes(String studentId, {int? limit}) async {
    try {
      Query<SessionNoteModel> q =
          _sessionNotesCol(studentId).orderBy('createdAt', descending: true);
      if (limit != null) q = q.limit(limit);
      final snap = await q.get();
      return snap.docs.map((d) => d.data()).toList();
    } on FirebaseException catch (e, st) {
      log('getSessionNotes error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('getSessionNotes unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Stream<List<SessionNoteModel>> streamSessionNotes(String studentId, {int? limit}) {
    Query<SessionNoteModel> q =
        _sessionNotesCol(studentId).orderBy('createdAt', descending: true);
    if (limit != null) q = q.limit(limit);
    return q.snapshots().map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> addSessionNote(String studentId, SessionNoteModel note) async {
    try {
      final ref = _sessionNotesCol(studentId).doc(note.id); // id stratejine göre
      await ref.set(note);
    } on FirebaseException catch (e, st) {
      log('addSessionNote error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('addSessionNote unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> updateSessionNote(String studentId, String noteId, Map<String, Object?> data, {bool merge = true}) async {
    try {
      final doc = _sessionNotesCol(studentId).doc(noteId);
      if (merge) {
 await doc.update(data); // update method is used for partial updates
      } else {
        await doc.update(data);
      }
    } on FirebaseException catch (e, st) {
      log('updateSessionNote error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('updateSessionNote unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<void> deleteSessionNote(String studentId, String noteId) async {
    try {
      await _sessionNotesCol(studentId).doc(noteId).delete();
    } on FirebaseException catch (e, st) {
      log('deleteSessionNote error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('deleteSessionNote unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  // -----------------------------
  // Users (teachers/parents) queries
  // -----------------------------
  Future<List<UserModel>> getTeachers({int? limit}) async {
    try {
      Query<UserModel> q = _usersCol.where('role', isEqualTo: 'teacher');
      if (limit != null) q = q.limit(limit);
      final snap = await q.get();
      return snap.docs.map((d) => d.data()).toList();
    } on FirebaseException catch (e, st) {
      log('getTeachers error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('getTeachers unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  Future<UserModel?> findParentByEmail(String email) async {
    try {
      final snap = await _usersCol
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'parent')
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) return snap.docs.first.data();
      return null;
    } on FirebaseException catch (e, st) {
      log('findParentByEmail error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('findParentByEmail unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }

  // -----------------------------
  // Relations / transactions example
  // -----------------------------
  Future<void> linkParentToStudent({required String studentId, required String parentUserId}) async {
    try {
      await _db.runTransaction((tx) async {
        final studentRef = _db.collection('students').doc(studentId);
        final parentRef = _db.collection('users').doc(parentUserId);

        tx.update(studentRef, {
          'parentIds': FieldValue.arrayUnion([parentUserId])
        });

        tx.set(parentRef, {
          'studentIds': FieldValue.arrayUnion([studentId])
        }, SetOptions(merge: true));
      });
    } on FirebaseException catch (e, st) {
      log('linkParentToStudent error: ${e.code} ${e.message}', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    } catch (e, st) {
      log('linkParentToStudent unexpected: $e', name: 'FirestoreService', error: e, stackTrace: st);
      rethrow;
    }
  }
}