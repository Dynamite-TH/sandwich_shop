import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Sandwich Shop',
      home: Scaffold(
        appBar: AppBar(title: const Text('Sandwich Counter')),
        body: Center(
          // child: SingleChildScrollView(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                // alignment: Alignment.center,
                color: Colors.blue,
                child: OrderItemDisplay(5, 'Club'),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.orange,
                child: OrderItemDisplay(3, 'BLT'),
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                color: Colors.green,
                child: OrderItemDisplay(2, 'Veggie'),
              ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.red,
              //   child: OrderItemDisplay(6, 'Ham'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.yellow,
              //   child: OrderItemDisplay(9, 'Turkey'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.purple,
              //   child: OrderItemDisplay(1, 'Chicken'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.pink,
              //   child: OrderItemDisplay(5, 'Jam'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.red,
              //   child: OrderItemDisplay(6, 'Ham'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.red,
              //   child: OrderItemDisplay(6, 'Ham'),
              // ),
              // Container(
              //   padding: EdgeInsets.all(8.0),
              //   color: Colors.red,
              //   child: OrderItemDisplay(6, 'Ham'),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItemDisplay extends StatelessWidget {
  final String itemType;
  final int quantity;

  const OrderItemDisplay(this.quantity, this.itemType, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      '$quantity $itemType sandwiches: ${'🥪' * quantity}',
      style: const TextStyle(fontSize: 20, color: Colors.white),
    );
  }
}
