import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/repositories/profile_provider.dart';
import 'package:sandwich_shop/views/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen view and edit flow', (WidgetTester tester) async {
    final provider = ProfileProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<ProfileProvider>.value(
        value: provider,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    // initial view shows app bar and Edit button
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);

    // enter edit mode
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    // should show text fields for name and email
    expect(find.byType(TextFormField), findsNWidgets(3));

    // enter values and save
    final nameField = find.byType(TextFormField).at(0);
    final emailField = find.byType(TextFormField).at(1);

    await tester.enterText(nameField, 'Alice');
    await tester.enterText(emailField, 'alice@example.com');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // snackbar shown and view mode restored
    expect(find.text('Profile saved'), findsOneWidget);
    // provider should have updated name
    expect(provider.name, 'Alice');
  });
}
