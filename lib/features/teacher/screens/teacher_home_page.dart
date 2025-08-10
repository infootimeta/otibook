import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:otibook/core/services/firestore_service.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';
import 'package:otibook/features/teacher/screens/qr_scanner_page.dart';
import 'package:otibook/models/student_model.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _scanQrCode() async {
    try {
      // GoRouter kullanıyorsan context.push ile de açabilirsin.
      // final qrCodeResult = await context.push<String?>('/scan'); // eğer route tanımlıysa
      final qrCodeResult = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const QRScannerPage()),
      );

      if (!mounted || qrCodeResult == null || qrCodeResult.isEmpty) return;

      final student = await _firestoreService.getStudentByQrCode(qrCodeResult);

      if (!mounted) return;

      if (student != null) {
        context.go('/teacher_home/student/${student.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu QR koda sahip bir öğrenci bulunamadı.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('QR okuma/arama hatası: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final displayName = user.nameSurname.isNotEmpty == true
        ? user.nameSurname
        : 'Öğretmen';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldin, $displayName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
              if (!mounted) return;
              context.go('/auth');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<StudentModel>>(
        future: _firestoreService.getAssignedStudents(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          final students = snapshot.data ?? const <StudentModel>[];
          if (students.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Size atanmış bir öğrenci bulunmamaktadır. Lütfen yöneticinizle görüşün.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _scanQrCode,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('QR Kod Okut'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(student.nameSurname),
                subtitle: Text('ID: ${student.id}'),
                onTap: () => context.go('/teacher_home/student/${student.id}'),
                trailing: IconButton(
                  tooltip: 'QR ile bul',
                  icon: const Icon(Icons.qr_code),
                  onPressed: _scanQrCode,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQrCode,
        label: const Text('QR Kod Okut'),
        icon: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
