import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';

class RoleGatePage extends StatefulWidget {
  const RoleGatePage({super.key});

  @override
  State<RoleGatePage> createState() => _RoleGatePageState();
}

class _RoleGatePageState extends State<RoleGatePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _redirectUser();
    });
  }

  void _redirectUser() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // AuthProvider'ın yüklenmesini bekle
    if (authProvider.authState == AuthState.unknown) {
      // Henüz auth durumu belli değilse kısa bir süre sonra tekrar dene
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _redirectUser();
        }
      });
      return;
    }

    final role = authProvider.userRole;

    if (role != null && mounted) {
      switch (role) {
        case 'teacher':
          context.go('/teacher_home');
          break;
        case 'parent':
          context.go('/parent_home');
          break;
        case 'admin':
          context.go('/admin_dashboard');
          break;
        default:
          // Tanımsız bir rol varsa veya bir sorun olursa giriş ekranına yönlendir.
          // Güvenlik önlemi olarak çıkış yaptırılabilir.
          authProvider.signOut();
          context.go('/auth');
      }
    } else if (mounted) {
      // Eğer bir şekilde rol bilgisi alınamazsa, bu bir hata durumudur.
      // Kullanıcıyı güvenli bir şekilde dışarı at.
      authProvider.signOut();
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yönlendirme işlemi anlık olacağı için kullanıcı genellikle bu ekranı görmez.
    // Bir sorun olması ihtimaline karşı bir yüklenme göstergesi gösterilir.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
