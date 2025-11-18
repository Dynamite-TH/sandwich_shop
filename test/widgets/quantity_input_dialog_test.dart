import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/views/quantity_modal.dart';

void main() {
  testWidgets('QuantityInputDialog shows validation and returns value', (
    WidgetTester tester,
  ) async {
    final resultNotifier = ValueNotifier<int?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await showDialog<int>(
                      context: context,
                      builder: (_) => const QuantityInputDialog(
                        initialQuantity: 1,
                        max: 10,
                      ),
                    );
                    resultNotifier.value = res;
                  },
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // open the dialog
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // enter invalid text
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // validation message appears
    expect(find.text('Please enter a valid number'), findsOneWidget);

    // enter out of range value
    await tester.enterText(find.byType(TextField), '0');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Minimum quantity is 1'), findsOneWidget);

    // enter valid value
    await tester.enterText(find.byType(TextField), '5');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // dialog dismissed and notifier holds the returned value
    expect(resultNotifier.value, 5);
  });
}
