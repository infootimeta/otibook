import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_oauth_apple/firebase_ui_oauth_apple.dart';

// Kendi AuthProvider'ınıza takma ad ekleyin
import 'package:otibook/features/auth/providers/auth_provider.dart' as my_auth_provider;
import 'package:otibook/core/services/auth_service.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Bu metot artık sadece yönlendirmeyi yönetir, kullanıcı durumunu kontrol etmez.
  Future<void> _handlePostAuthFlow(BuildContext context, String uid) async {
    // context'in mount edilip edilmediğini kontrol edin.
    if (!context.mounted) {
      return;
    }

    final authService = AuthService();
    final userProfile = await authService.getUserProfile(uid);

    if (!context.mounted) return;

    if (userProfile == null) {
      context.go('/create_profile');
    } else {
      // Kendi AuthProvider'ınızı takma adıyla çağırın.
      final myAuthProvider = Provider.of<my_auth_provider.AuthProvider>(context, listen: false);
      await myAuthProvider.refreshUserProfile();
      if (!context.mounted) return;
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tüm akış mantığını tek bir StreamBuilder içinde yönetmek en iyi yaklaşımdır.
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Bağlantı durumu bekleniyorsa bir yükleme ekranı gösterin.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Eğer kullanıcı verisi varsa, profil kontrolünü başlatın.
        if (snapshot.hasData) {
          final user = snapshot.data;
          // Asenkron bir işlem için `addPostFrameCallback` kullanın.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (user != null) {
              _handlePostAuthFlow(context, user.uid);
            }
          });
          // Yönlendirme gerçekleşene kadar bir yükleme ekranı gösterin.
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Eğer kullanıcı verisi yoksa, giriş ekranını gösterin.
        return SignInScreen(
          providers: [
            EmailAuthProvider(),
            GoogleProvider(clientId: 'YOUR_GOOGLE_CLIENT_ID'),
            AppleProvider(),
          ],
          actions: [
            // Kullanıcı başarıyla giriş yaptığında yönlendirme işlemlerini başlatır.
            AuthStateChangeAction<SignedIn>((context, state) {
              if (state.user != null) {
                // Giriş yapma anında yönlendirme akışını başlatın.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    _handlePostAuthFlow(context, context.mounted ? state.user!.uid : '');
                });
              }
            }),
            AuthStateChangeAction<UserCreated>((context, state) {
              // Kullanıcının UID'sini al
              final uid = state.credential.user?.uid;
              if (uid != null) {
                // Yeni kullanıcı oluşturulduğunda yönlendirme akışını başlatın.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _handlePostAuthFlow(context, uid);
                });
              }
            }),
          ],
        );
      },
    );
  }
}