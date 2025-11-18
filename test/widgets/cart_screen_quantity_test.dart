import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  group('CartScreen quantity buttons', () {
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

    testWidgets('tapping + increases quantity and updates total', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
      await tester.pumpAndSettle();

      // initial quantity shown
      expect(find.textContaining('Qty:'), findsOneWidget);

      // tap + button
      final Finder addButton = find.byIcon(Icons.add_circle_outline);
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // quantity should increase to 2
      expect(find.textContaining('Qty: 2'), findsOneWidget);
      // total should be shown and > 0
      expect(find.textContaining('Total:'), findsOneWidget);
    });

    testWidgets('tapping - decreases quantity and removes when 0', (
      WidgetTester tester,
    ) async {
      // start with quantity 1, tapping - should remove the item
      await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
      await tester.pumpAndSettle();

      final Finder removeButton = find.byIcon(Icons.remove_circle_outline);
      expect(removeButton, findsOneWidget);
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      // after removal, cart should be empty and empty message or no Qty shown
      expect(find.textContaining('Qty:'), findsNothing);
    });
  });
}
