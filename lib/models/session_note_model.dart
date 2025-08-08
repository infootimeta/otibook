import 'package:cloud_firestore/cloud_firestore.dart';

class SessionNoteModel {
  final String id;
  final Timestamp createdAt;
  final String? noteText;
  final String? mediaUrl;
  final String? audioUrl;
  final DocumentReference studentRef;
  final DocumentReference teacherRef;

  SessionNoteModel({
    required this.id,
    required this.createdAt,
    this.noteText,
    this.mediaUrl,
    this.audioUrl,
    required this.studentRef,
    required this.teacherRef,
  });

  // Firestore dökümanından SessionNoteModel objesi oluşturmak için
  factory SessionNoteModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SessionNoteModel(
      id: doc.id,
      createdAt: data['created_at'] ?? Timestamp.now(),
      noteText: data['note_text'],
      mediaUrl: data['media_url'],
      audioUrl: data['audio_url'],
      studentRef: data['student_ref'],
      teacherRef: data['teacher_ref'],
    );
  }

  // SessionNoteModel objesini Firestore'a yazmak için Map'e dönüştüren metot
  Map<String, dynamic> toMap() {
    return {
      'created_at': createdAt,
      'note_text': noteText,
      'media_url': mediaUrl,
      'audio_url': audioUrl,
      'student_ref': studentRef,
      'teacher_ref': teacherRef,
    };
  }
}
