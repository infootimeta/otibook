import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Widget test framework çalışıyor', (WidgetTester tester) async {
    // Test framework'ün çalıştığını doğruluyoruz
    expect(true, isTrue);

    // Basit bir widget test yapıyoruz
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test App')),
          body: const Center(child: Text('Test başarılı!')),
        ),
      ),
    );

    // Widget'ların doğru şekilde render edildiğini doğruluyoruz
    expect(find.text('Test App'), findsOneWidget);
    expect(find.text('Test başarılı!'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
