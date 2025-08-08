import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';
import 'package:otibook/models/student_model.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findAndRedirectToChild();
    });
  }

  Future<void> _findAndRedirectToChild() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      // Güvenlik önlemi, normalde bu ekrana user olmadan gelinmemeli
      context.go('/auth');
      return;
    }

    try {
      final parentRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);

      final studentQuery =
          await FirebaseFirestore.instance
              .collection('students')
              .where('parent_ref', isEqualTo: parentRef)
              .limit(1)
              .get();

      if (studentQuery.docs.isNotEmpty) {
        final student = StudentModel.fromFirestore(studentQuery.docs.first);
        if (mounted) {
          // Veli, öğretmen detay sayfasıyla aynı sayfayı kullanacak
          // Fakat sayfa içindeki yetkiler (örn. not ekleme butonu) rol'e göre gizlenebilir.
          // Şimdilik direkt yönlendirme yapıyoruz.
          context.go('/teacher_home/student/${student.id}');
        }
      } else {
        // Velinin atanmış bir çocuğu yoksa bilgilendirme ekranı göster
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const NoChildAssignedScreen()),
          );
        }
      }
    } catch (e) {
      // Hata durumunda bilgilendirme
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => InfoScreen(
                  message: 'Veriler alınırken bir hata oluştu: $e',
                ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yönlendirme yapılırken bekleme ekranı
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Öğrenci bilgileriniz alınıyor...'),
          ],
        ),
      ),
    );
  }
}

// Velinin çocuğu olmadığında gösterilecek ekran
class NoChildAssignedScreen extends StatelessWidget {
  const NoChildAssignedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgilendirme')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, size: 60, color: Colors.blue),
              const SizedBox(height: 20),
              const Text(
                'Sisteme kayıtlı bir öğrenciniz bulunmamaktadır.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Lütfen kurum yöneticinizle iletişime geçin.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                  context.go('/auth');
                },
                child: const Text('Çıkış Yap'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Genel bir bilgilendirme ekranı
class InfoScreen extends StatelessWidget {
  final String message;
  const InfoScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bilgilendirme')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
