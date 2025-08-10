import 'package:flutter/material.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/firestore_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/session_note_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewNotePage extends StatefulWidget {
  final String studentId;
  const NewNotePage({super.key, required this.studentId});

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final txt = TextEditingController();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final fs = sl<FirestoreService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Oturum Notu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: txt,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Not',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      setState(() => saving = true);
                      try {
                        final teacherId = context
                            .read<AuthProvider>()
                            .user
                            ?.uid;
                        if (teacherId == null) {
                          throw Exception('Teacher ID not found.');
                        }
                        final note = SessionNoteModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          noteText: txt.text.trim(),
                          studentRef: fs.getStudentReference(widget.studentId),
                          teacherRef: fs.getUserReference(teacherId),
                          createdAt: Timestamp.now(),
                        );
                        await fs.addSessionNote(widget.studentId, note);
                        // ignore: use_build_context_synchronously
                        if (mounted) Navigator.pop(context, true);
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(fs.getFirestoreErrorMessage(e)),
                          ),
                        );
                      } finally {
                        if (mounted) setState(() => saving = false);
                      }
                    },
              child: Text(saving ? 'Kaydediliyor...' : 'Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
