import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  group('CartScreen remove and undo', () {
    late Cart cart;
    late Sandwich sandwich;

    setUp(() {
      cart = Cart();
      sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      cart.add(sandwich);
    });

    testWidgets('tap delete removes item and undo restores it', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CartScreen()));
      await tester.pumpAndSettle();

      // ensure item present
      expect(find.text(sandwich.name), findsOneWidget);

      // tap trash icon
      final Finder trash = find.byIcon(Icons.delete_outline);
      expect(trash, findsOneWidget);
      await tester.tap(trash);
      await tester.pumpAndSettle();

      // item should be removed
      expect(find.text(sandwich.name), findsNothing);

      // SnackBar with Undo should appear
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      // item restored
      expect(find.text(sandwich.name), findsOneWidget);
    });
  });
}
