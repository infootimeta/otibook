import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:otibook/core/routing/app_router.dart';
import 'package:otibook/features/auth/providers/auth_provider.dart';
import 'firebase_options.dart';

void main() async {
  // Flutter binding'lerinin hazır olduğundan emin ol
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i başlat
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // Provider'ları tüm uygulamaya tanıt
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Diğer provider'lar buraya eklenecek
      ],
      child: const otibookApp(),
    ),
  );
}

// ignore: camel_case_types
class otibookApp extends StatelessWidget {
  const otibookApp({super.key});

  @override
  Widget build(BuildContext context) {
    // AppRouter'ı oluştur
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'otibook - Dijital Gelişim Defteri',
      debugShowCheckedModeBanner: false,

      // Tema Ayarları
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.nunitoSansTextTheme(Theme.of(context).textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: GoogleFonts.nunitoSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),

      // GoRouter yapılandırması
      routerConfig: appRouter.router,
    );
  }
}
