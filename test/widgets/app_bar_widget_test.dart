import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/widgets/common_widgets.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  testWidgets('AppBarWidget shows title and cart count updates', (
    WidgetTester tester,
  ) async {
    final cart = Cart();

    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>.value(
        value: cart,
        child: MaterialApp(
          home: Scaffold(
            appBar: const AppBarWidget('Test Title'),
            body: const SizedBox.shrink(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // title is shown
    expect(find.text('Test Title'), findsOneWidget);

    // initial cart count is 0
    expect(find.text('0'), findsOneWidget);

    // add one sandwich and ensure the count updates
    cart.add(
      Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: false,
        breadType: BreadType.white,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
