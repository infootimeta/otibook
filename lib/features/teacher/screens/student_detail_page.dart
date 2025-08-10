import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:otibook/core/services/firestore_service.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';
import 'package:otibook/models/session_note_model.dart';
import 'package:otibook/models/student_model.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

class StudentDetailPage extends StatefulWidget {
  final String studentId;
  const StudentDetailPage({super.key, required this.studentId});

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isTeacher = authProvider.userRole == 'teacher';

    return FutureBuilder<StudentModel?>(
      future: _firestoreService.getStudentDetails(widget.studentId),
      builder: (context, studentSnapshot) {
        final studentName =
            studentSnapshot.data?.nameSurname ?? 'Öğrenci Notları';

        return Scaffold(
          appBar: AppBar(title: Text(studentName)),
          body: StreamBuilder<List<SessionNoteModel>>(
            stream: _firestoreService.streamSessionNotes(widget.studentId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Bir hata oluştu: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Bu öğrenciye ait hiç not bulunamadı.'),
                );
              }

              final notes = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return _buildNoteCard(note);
                },
              );
            },
          ),
          floatingActionButton:
              isTeacher
                  ? FloatingActionButton(
                    onPressed: () {
                      context.go(
                        '/teacher_home/student/${widget.studentId}/add_note',
                      );
                    },
                    tooltip: 'Yeni Not Ekle',
                    child: const Icon(Icons.add),
                  )
                  : null, // Veli ise butonu gösterme
        );
      },
    );
  }

  Widget _buildNoteCard(SessionNoteModel note) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'd MMMM yyyy, HH:mm',
                'tr_TR',
              ).format(note.createdAt.toDate()),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const Divider(),
            if (note.mediaUrl != null && note.mediaUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: () => _showImageDialog(context, note.mediaUrl!),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      note.mediaUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (note.noteText != null && note.noteText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  note.noteText!,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            if (note.audioUrl != null && note.audioUrl!.isNotEmpty)
              _buildAudioPlayer(note.audioUrl!),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer(String audioUrl) {
    final isPlaying = _currentlyPlayingUrl == audioUrl;
    return Center(
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
          size: 40,
        ),
        onPressed: () async {
          if (isPlaying) {
            await _audioPlayer.pause();
            setState(() {
              _currentlyPlayingUrl = null;
            });
          } else {
            await _audioPlayer.play(UrlSource(audioUrl));
            setState(() {
              _currentlyPlayingUrl = audioUrl;
            });
            _audioPlayer.onPlayerComplete.first.then((_) {
              if (mounted) {
                setState(() {
                  _currentlyPlayingUrl = null;
                });
              }
            });
          }
        },
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Image.network(imageUrl),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white, size: 30), // Specify parameters to all arguments in declaration. 
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
