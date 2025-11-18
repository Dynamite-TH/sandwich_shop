import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/views/checkout_screen.dart';

void main() {
  group('CheckoutScreen', () {
    late Cart cart;
    late Sandwich sandwichA;

    setUp(() {
      cart = Cart();
      sandwichA = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.wholemeal,
      );
      cart.add(sandwichA, quantity: 2);
    });

    testWidgets('displays order summary and total, and processes payment', (
      WidgetTester tester,
    ) async {
      // Test harness that pushes CheckoutScreen and displays returned result
      Map? result;

      await tester.pumpWidget(
        MaterialApp(
          home: TestHarness(cart: cart, onResult: (r) => result = r),
        ),
      );

      // Open the checkout screen
      await tester.tap(find.text('Open Checkout'));
      await tester.pumpAndSettle();

      // Verify order summary and total are displayed
      expect(find.text('Order Summary'), findsOneWidget);
      expect(find.textContaining('Tuna Melt'), findsOneWidget);
      expect(find.textContaining('Total:'), findsOneWidget);

      // Tap Confirm Payment
      expect(find.text('Confirm Payment'), findsOneWidget);
      await tester.tap(find.text('Confirm Payment'));
      await tester.pump();

      // Should show processing indicator and text
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing payment...'), findsOneWidget);

      // Advance time to let the fake processing finish
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // The TestHarness should have received a result map with orderId and totalAmount
      expect(result, isNotNull);
      expect(result!['orderId'], startsWith('ORD'));
      expect(result!['totalAmount'], isA<double>());
      expect(result!['itemCount'], equals(cart.countOfItems));
    });
  });
}

class TestHarness extends StatefulWidget {
  final Cart cart;
  final void Function(Map) onResult;

  const TestHarness({super.key, required this.cart, required this.onResult});

  @override
  State<TestHarness> createState() => _TestHarnessState();
}

class _TestHarnessState extends State<TestHarness> {
  Map? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final res = await Navigator.of(context).push<Map>(
                  MaterialPageRoute(
                    builder: (_) => CheckoutScreen(cart: widget.cart),
                  ),
                );
                if (res != null) {
                  setState(() => _result = res);
                  widget.onResult(res);
                }
              },
              child: const Text('Open Checkout'),
            ),
            const SizedBox(height: 12),
            if (_result != null) Text('orderId: ${_result!['orderId']}'),
          ],
        ),
      ),
    );
  }
}
