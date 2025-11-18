import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/about_screen.dart';

void main() {
  testWidgets('AboutScreen shows expected texts', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutScreen()));

    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Welcome to Sandwich Shop!'), findsOneWidget);
    expect(find.textContaining('family-owned'), findsOneWidget);
  });
}
