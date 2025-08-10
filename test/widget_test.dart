import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:otibook/main.dart'; // Doğru main.dart dosyasını import ediyoruz
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

void main() {
  testWidgets('otibookApp başarıyla başlatılıyor ve title gösteriliyor', (WidgetTester tester) async {
    // Mock Firebase App
    // final mockApp = MockFirebaseApp();
    // when(mockApp.name).thenReturn('[DEFAULT]');
    // when(mockApp.options).thenReturn(const FirebaseOptions(
    //   apiKey: 'test',
    //   appId: 'test',
    //   messagingSenderId: 'test',
    //   projectId: 'test',
    // ));

    // Mock Firebase initialization
    await Firebase.initializeApp();

    // Uygulamanızın ana widget'ı olan otibookApp'i oluşturup bir frame tetikliyoruz.
    await tester.pumpWidget(const OtibookApp());

    // Uygulamanın başlığının (title) görünür olduğunu doğruluyoruz.
    // 'otibook - Dijital Gelişim Defteri' metninin widget ağacında bulunup bulunmadığını kontrol ediyoruz.
    expect(find.text('otibook - Dijital Gelişim Defteri'), findsOneWidget);

    // Uygulamanın debug banner'ı göstermediğini de doğrulayabiliriz.
    expect(find.byType(CheckedModeBanner), findsNothing);
  });
}
