import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  testWidgets('shows empty cart placeholder when cart is empty', (
    WidgetTester tester,
  ) async {
    final cart = Cart();
    await tester.pumpWidget(MaterialApp(home: CartScreen(cart: cart)));
    await tester.pumpAndSettle();

    expect(find.text('Your cart is empty'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
  });
}
