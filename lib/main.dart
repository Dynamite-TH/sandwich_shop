import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:sandwich_shop/views/about_screen.dart';
import 'package:sandwich_shop/views/profile_screen.dart';
import 'package:sandwich_shop/repositories/profile_provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MaterialApp(
        title: 'Sandwich Shop App',
        home: OrderScreen(maxQuantity: 5),
        initialRoute: '/',
        routes: {
          '/about': (context) => AboutScreen(),
          '/profile': (context) => ProfileScreen(),
        },
      ),
    );
  }
}
