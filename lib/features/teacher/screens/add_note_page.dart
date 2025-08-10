import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'package:otibook/core/services/firestore_service.dart';
import 'package:otibook/core/services/storage_service.dart';
import 'package:otibook/models/session_note_model.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';

class AddNotePage extends StatefulWidget {
  final String studentId;
  const AddNotePage({super.key, required this.studentId});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _noteController = TextEditingController();
  final _firestoreService = FirestoreService();
  final _storageService = StorageService();

  // record >= 5.x ile AudioRecorder sınıfı var. Eski sürümlerde Record() kullanılır.
  final _audioRecorder = AudioRecorder();

  bool _isLoading = false;
  File? _imageFile;
  String? _audioPath;
  bool _isRecording = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
        });
      }
    } else {
      final hasPerm = await _audioRecorder.hasPermission();
      if (hasPerm) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _audioPath = null; // önceki kaydı temizle
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mikrofon izni gerekli.')));
      }
    }
  }

  Future<void> _saveNote() async {
    if (_noteController.text.trim().isEmpty &&
        _imageFile == null &&
        _audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Kaydetmek için en az bir not, resim veya ses kaydı eklemelisiniz.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final teacherId = context.read<AuthProvider>().user?.uid;
    if (teacherId == null) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kullanıcı oturumu bulunamadı.')),
      );
      return;
    }

    try {
      String? imageUrl;
      String? audioUrl;

      if (_imageFile != null) {
        imageUrl = await _storageService.uploadImage(
          _imageFile!,
          widget.studentId,
        );
      }
      if (_audioPath != null) {
        audioUrl = await _storageService.uploadAudio(
          _audioPath!,
          widget.studentId,
        );
      }

      final note = SessionNoteModel(
        id: const Uuid().v4(),
        noteText: _noteController.text.trim(),
        mediaUrl: imageUrl,
        audioUrl: audioUrl,
        createdAt: Timestamp.now(),
        studentRef: _firestoreService.getStudentDocumentRef(widget.studentId),
        teacherRef: _firestoreService.getTeacherDocumentRef(teacherId),
      );

      await _firestoreService.addSessionNote(widget.studentId, note);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not başarıyla kaydedildi!')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Ders Notu Ekle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ders Notu',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeriden'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Kaydı Durdur' : 'Ses Kaydı Başlat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.red : primary,
              ),
            ),
            if (_audioPath != null && !_isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Ses kaydı tamamlandı.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green[700]),
                ),
              ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveNote,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Notu Kaydet'),
                  ),
          ],
        ),
      ),
    );
  }
}

/// FirestoreService için yardımcı referans getter'ları.
/// İstersen doğrudan FirestoreService içine koy.
extension FirestoreRefs on FirestoreService {
  DocumentReference<Map<String, dynamic>> getStudentDocumentRef(
    String studentId,
  ) {
    return FirebaseFirestore.instance.collection('students').doc(studentId);
  }

  DocumentReference<Map<String, dynamic>> getTeacherDocumentRef(
    String teacherId,
  ) {
    return FirebaseFirestore.instance.collection('teachers').doc(teacherId);
  }
}
