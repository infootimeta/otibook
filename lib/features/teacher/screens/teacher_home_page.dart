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
    // QR Tarayıcı sayfasını aç ve bir sonuç bekle.
    final qrCodeResult = await Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (context) => const QRScannerPage()),
    );

    if (qrCodeResult != null && qrCodeResult.isNotEmpty && mounted) {
      // Dönen QR kod verisi ile öğrenciyi ara
      final student = await _firestoreService.getStudentByQrCode(qrCodeResult);

      if (student != null && mounted) {
        // Öğrenci bulunduysa detay sayfasına yönlendir
        context.go('/teacher_home/student/${student.id}');
      } else if (mounted) {
        // Öğrenci bulunamadıysa uyarı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu QR koda sahip bir öğrenci bulunamadı.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      // Eğer kullanıcı bilgisi henüz yüklenmediyse bekleme ekranı göster
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoş Geldin, ${user.nameSurname}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/auth');
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: StreamBuilder<List<StudentModel>>(
        stream: _firestoreService.getAssignedStudents(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Size atanmış bir öğrenci bulunmamaktadır. Lütfen yöneticinizle görüşün.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(student.nameSurname),
                subtitle: Text('ID: ${student.id}'),
                onTap: () {
                  context.go('/teacher_home/student/${student.id}');
                },
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
