import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/profile_screen.dart';
import 'package:sandwich_shop/models/cart.dart';

void main() {
  testWidgets('ProfileScreen save returns entered data', (
    WidgetTester tester,
  ) async {
    // Will hold the popped result from ProfileScreen
    final resultNotifier = ValueNotifier<Map<String, String>?>(null);

    await tester.pumpWidget(
      ChangeNotifierProvider<Cart>(
        create: (_) => Cart(),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final res = await Navigator.of(context)
                          .push<Map<String, String>>(
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
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
      ),
    );

    // open the profile screen
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // enter name and location
    await tester.enterText(find.byType(TextField).at(0), 'Alice');
    await tester.enterText(find.byType(TextField).at(1), 'Wonderland');

    // save and pop
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    // dialog/screen dismissed and notifier holds the returned map
    expect(resultNotifier.value, isNotNull);
    expect(resultNotifier.value!['name'], 'Alice');
    expect(resultNotifier.value!['location'], 'Wonderland');
  });
}
