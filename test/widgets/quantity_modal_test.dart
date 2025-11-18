import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/quantity_modal.dart';

void main() {
  testWidgets('QuantityInputDialog validates input and returns value', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                final res = await showDialog<int>(
                  context: context,
                  builder: (_) => const QuantityInputDialog(initialQuantity: 1),
                );
                // push a Text widget to surface the result in the widget tree
                if (res != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('got:$res')));
                }
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // dialog shown
    expect(find.text('Set quantity'), findsOneWidget);

    // enter invalid input
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    // should show validation error
    expect(find.textContaining('Minimum quantity'), findsOneWidget);

    // enter valid input
    await tester.enterText(find.byType(TextField), '3');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // SnackBar should be shown with the returned value
    expect(find.textContaining('got:3'), findsOneWidget);
  });
}
