import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/models/cart.dart';

class CartView extends StatelessWidget {
  final Cart cart;

  const CartView({super.key, required this.cart});

  String _formatPrice(double v) => '\$${v.toStringAsFixed(2)}';

  String _assetPath(String path) {
    if (path.startsWith('/')) return path.substring(1);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final items = cart.items;
        if (items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Text('Your cart is empty', textAlign: TextAlign.center),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(30),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            final sandwich = item.sandwich;
            final unitPrice = item.unitPrice(
              cart.pricingRepo,
              toastedFee: cart.toastedFee,
            );
            final totalPrice = item.totalPrice(
              cart.pricingRepo,
              toastedFee: cart.toastedFee,
            );

            final imagePath = _assetPath(sandwich.image);

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // reuse existing edit sheet code
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (ctx) {
                      final qtyController = TextEditingController(
                        text: item.quantity.toString(),
                      );
                      final noteController = TextEditingController(
                        text: item.note,
                      );
                      bool toasted = item.isToasted;
                      String toastedValue;
                      if (toasted == true) {
                        toastedValue = "Toasted";
                      } else {
                        toastedValue = "Untoasted";
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
                          left: 16,
                          right: 16,
                          top: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Edit ${sandwich.name}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Text('Quantity:'),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: qtyController,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: noteController,
                              decoration: const InputDecoration(
                                labelText: 'Note',
                              ),
                            ),
                            SwitchListTile(
                              title: Text(toastedValue),
                              value: toasted,
                              onChanged: (v) => toasted = v,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              child: const Text('Save'),
                              onPressed: () {
                                final newQty =
                                    int.tryParse(qtyController.text) ??
                                    item.quantity;
                                final updated = item.copyWith(
                                  quantity: newQty,
                                  note: noteController.text,
                                  isToasted: toasted,
                                );
                                cart.amendItem(item.id, updated);
                                Navigator.of(ctx).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // <- align children to top
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          imagePath,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.fastfood, size: 40),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Flexible middle column aligned to top-left
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${item.quantity} × ${sandwich.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              sandwich.isFootlong
                                  ? 'Footlong • ${sandwich.breadType.name}'
                                  : '6-inch • ${sandwich.breadType.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (item.isToasted) ...[
                              const SizedBox(height: 6),
                              const Text(
                                'Toasted',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                            if (item.note.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Note: ${item.note}',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // compact trailing column (price + actions)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(unitPrice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_formatPrice(totalPrice)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => cart.decreaseQuantity(item.id),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => cart.removeItemById(item.id),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

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
  // Cart will use a default PricingRepository if none is provided.
  final Cart _cart = Cart();
  final TextEditingController _notesController = TextEditingController();

  SandwichType _selectedSandwichType = SandwichType.veggieDelight;
  bool _isFootlong = true;
  BreadType _selectedBreadType = BreadType.white;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_quantity > 0) {
      final Sandwich sandwich = Sandwich(
        type: _selectedSandwichType,
        isFootlong: _isFootlong,
        breadType: _selectedBreadType,
      );

      setState(() {
        _cart.addItem(OrderItem(sandwich: sandwich, quantity: _quantity));
      });

      String sizeText;
      if (_isFootlong) {
        sizeText = 'footlong';
      } else {
        sizeText = 'six-inch';
      }
      String confirmationMessage =
          'Added $_quantity $sizeText ${sandwich.name} sandwich(es) on ${_selectedBreadType.name} bread to cart';

      debugPrint(confirmationMessage);

      // show confirmation snackbar in the UI
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text(confirmationMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      _showCartSummary();
    }
  }

  VoidCallback? _getAddToCartCallback() {
    if (_quantity > 0) {
      return _addToCart;
    }
    return null;
  }

  void _showCartSummary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: CartView(cart: _cart),
      ),
    );
  }

  List<DropdownMenuEntry<SandwichType>> _buildSandwichTypeEntries() {
    List<DropdownMenuEntry<SandwichType>> entries = [];
    for (SandwichType type in SandwichType.values) {
      Sandwich sandwich = Sandwich(
        type: type,
        isFootlong: true,
        breadType: BreadType.white,
      );
      DropdownMenuEntry<SandwichType> entry = DropdownMenuEntry<SandwichType>(
        value: type,
        label: sandwich.name,
      );
      entries.add(entry);
    }
    return entries;
  }

  List<DropdownMenuEntry<BreadType>> _buildBreadTypeEntries() {
    List<DropdownMenuEntry<BreadType>> entries = [];
    for (BreadType bread in BreadType.values) {
      DropdownMenuEntry<BreadType> entry = DropdownMenuEntry<BreadType>(
        value: bread,
        label: bread.name,
      );
      entries.add(entry);
    }
    return entries;
  }

  String _getCurrentImagePath() {
    final Sandwich sandwich = Sandwich(
      type: _selectedSandwichType,
      isFootlong: _isFootlong,
      breadType: _selectedBreadType,
    );
    return sandwich.image;
  }

  void _onSandwichTypeChanged(SandwichType? value) {
    if (value != null) {
      setState(() {
        _selectedSandwichType = value;
      });
    }
  }

  void _onSizeChanged(bool value) {
    setState(() {
      _isFootlong = value;
    });
  }

  void _onBreadTypeChanged(BreadType? value) {
    if (value != null) {
      setState(() {
        _selectedBreadType = value;
      });
    }
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 0) {
      setState(() {
        _quantity--;
      });
    }
  }

  VoidCallback? _getDecreaseCallback() {
    if (_quantity > 0) {
      return _decreaseQuantity;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: SizedBox(
          height: 100,
          child: Image.asset('assets/images/logo.png'),
        ),
        title: const Text('Sandwich Counter', style: heading1),
        actions: [
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
              final total = _cart.items.fold<int>(
                0,
                (s, it) => s + it.quantity,
              );
              return IconButton(
                onPressed: _showCartSummary,
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (total > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 300,
                child: Image.asset(
                  _getCurrentImagePath(),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Image not found', style: normalText),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              DropdownMenu<SandwichType>(
                width: double.infinity,
                label: const Text('Sandwich Type'),
                textStyle: normalText,
                initialSelection: _selectedSandwichType,
                onSelected: _onSandwichTypeChanged,
                dropdownMenuEntries: _buildSandwichTypeEntries(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Six-inch', style: normalText),
                  Switch(value: _isFootlong, onChanged: _onSizeChanged),
                  const Text('Footlong', style: normalText),
                ],
              ),
              const SizedBox(height: 20),
              DropdownMenu<BreadType>(
                width: double.infinity,
                label: const Text('Bread Type'),
                textStyle: normalText,
                initialSelection: _selectedBreadType,
                onSelected: _onBreadTypeChanged,
                dropdownMenuEntries: _buildBreadTypeEntries(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Quantity: ', style: normalText),
                  IconButton(
                    onPressed: _getDecreaseCallback(),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$_quantity', style: heading2),
                  IconButton(
                    onPressed: _increaseQuantity,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StyledButton(
                onPressed: _getAddToCartCallback(),
                icon: Icons.add_shopping_cart,
                label: 'Add to Cart',
                backgroundColor: Colors.green,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class StyledButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;

  const StyledButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
  });
  @override
  Widget build(BuildContext context) {
    ButtonStyle myButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      textStyle: normalText,
    );

    return ElevatedButton(
      onPressed: onPressed,
      style: myButtonStyle,
      child: Row(children: [Icon(icon), const SizedBox(width: 8), Text(label)]),
    );
  }
}

class OrderItemDisplay extends StatelessWidget {
  final int quantity;
  final String itemType;
  final BreadType breadType;
  final String orderNote;
  final bool isToasted;
  final double price;

  const OrderItemDisplay({
    super.key,
    required this.quantity,
    required this.itemType,
    required this.breadType,
    required this.orderNote,
    required this.isToasted,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final safeQuantity = quantity.clamp(0, 100);
    final emoji = List.filled(safeQuantity, '🥪').join();
    final String toastStatus = isToasted ? 'toasted' : 'untoasted';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$quantity ${breadType.name} $itemType sandwich(es): $emoji',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 10),
        Text('Price: \$${price.toStringAsFixed(2)}'),
        const SizedBox(height: 6),
        Text('Bread: ${breadType.name}'),
        Text('Type: $toastStatus'),
        const SizedBox(height: 4),
        Text(
          orderNote.isEmpty ? 'No notes added.' : 'Note: $orderNote',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
