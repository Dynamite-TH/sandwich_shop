import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Sandwich Shop App',
      home: OrderScreen(maxQuantity: 5),
    );
  }
}

enum SandwichSize { footlong, sixInch }

class OrderScreen extends StatefulWidget {
  final int maxQuantity;

  const OrderScreen({super.key, this.maxQuantity = 20});

  @override
  State<OrderScreen> createState() {
    return _OrderScreenState();
  }
}

class _OrderScreenState extends State<OrderScreen> {
  int _quantity = 0;
  final TextEditingController _noteController = TextEditingController();
  final List<String> _modifications = []; // one entry per added sandwich
  SandwichSize _selectedSize = SandwichSize.footlong;

  void _increaseQuantity() {
    if (_quantity >= widget.maxQuantity) return;
    final note = _noteController.text.trim();
    setState(() {
      _quantity++;
      _modifications.add(note); // keep alignment: even empty note is stored
      _noteController.clear();
    });
  }

  void _decreaseQuantity() {
    if (_quantity <= 0) return;
    setState(() {
      _quantity--;
      if (_modifications.isNotEmpty) _modifications.removeLast();
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _decreaseAllQuantity() {
    setState(() {
      _quantity = 0;
      _modifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemLabel = _selectedSize == SandwichSize.footlong
        ? 'Footlong'
        : 'Six-inch';
    return Scaffold(
      appBar: AppBar(title: const Text('Sandwich Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: SegmentedButton<SandwichSize>(
                segments: const <ButtonSegment<SandwichSize>>[
                  ButtonSegment(
                    value: SandwichSize.footlong,
                    label: Text('Footlong', style: heading1),
                  ),
                  ButtonSegment(
                    value: SandwichSize.sixInch,
                    label: Text('Six-inch', style: heading1),
                  ),
                ],
                selected: <SandwichSize>{_selectedSize},
                onSelectionChanged: (Set<SandwichSize> newSelection) {
                  if (newSelection.isNotEmpty) {
                    setState(() {
                      _selectedSize = newSelection.first;
                    });
                  }
                },
              ),
            ),
            OrderItemDisplay(_quantity, itemLabel),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Special Instructions',
                  hintText: 'e.g., No pickles, extra mayo',
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (_quantity >= widget.maxQuantity)
                      ? null
                      : _increaseQuantity,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
                ElevatedButton(
                  onPressed: (_quantity <= 0) ? null : _decreaseQuantity,
                  onLongPress: (_quantity > 0) ? _decreaseAllQuantity : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Remove'),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: Text(
                    _modifications.where((s) => s.isNotEmpty).join(', '),
                  ),
                ),
              ],
            ),
          ],
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
      style: const TextStyle(fontSize: 20),
    );
  }
}
