import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/order_screen.dart'; // contains StyledButton

void main() {
  testWidgets('StyledButton renders and responds to tap', (
    WidgetTester tester,
  ) async {
    int pressed = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: StyledButton(
              onPressed: () => pressed++,
              icon: Icons.add,
              label: 'Test',
              backgroundColor: Colors.purple,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Test'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byType(StyledButton));
    await tester.pumpAndSettle();

    expect(pressed, 1);
  });
}
