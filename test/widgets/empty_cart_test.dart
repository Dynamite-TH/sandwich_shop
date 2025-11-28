import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/views/cart_screen.dart';

void main() {
  testWidgets('shows empty cart placeholder when cart is empty', (
    WidgetTester tester,
  ) async {
    // empty cart
    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: Cart(),
        child: MaterialApp(home: CartScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // message includes a trailing period in the UI
    expect(find.text('Your cart is empty.'), findsOneWidget);
  });
}
