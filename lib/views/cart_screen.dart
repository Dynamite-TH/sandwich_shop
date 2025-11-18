import 'package:flutter/material.dart';
import 'package:sandwich_shop/views/app_styles.dart';
import 'package:sandwich_shop/views/order_screen.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';
import 'package:sandwich_shop/views/quantity_modal.dart';

class CartScreen extends StatefulWidget {
  final Cart cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() {
    return _CartScreenState();
  }
}

class _CartScreenState extends State<CartScreen> {
  void _goBack() {
    Navigator.pop(context);
  }

  String _getSizeText(bool isFootlong) {
    if (isFootlong) {
      return 'Footlong';
    } else {
      return 'Six-inch';
    }
  }

  double _getItemPrice(Sandwich sandwich, int quantity) {
    final PricingRepository pricingRepository = PricingRepository();
    return pricingRepository.calculatePrice(
      quantity: quantity,
      isFootlong: sandwich.isFootlong,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: 100,
            child: Image.asset('assets/images/logo.png'),
          ),
        ),
        title: const Text('Cart View', style: heading1),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              if (widget.cart.isEmpty)
                Column(
                  children: const [
                    SizedBox(height: 40),
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                  ],
                )
              else
                for (MapEntry<Sandwich, int> entry in widget.cart.items.entries)
                  Dismissible(
                    key: ValueKey(entry.key.hashCode),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) {
                      final removed = entry.key;
                      final removedQty = entry.value;
                      setState(() {
                        widget.cart.remove(removed, quantity: removedQty);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${removed.name} removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              setState(() {
                                widget.cart.add(removed, quantity: removedQty);
                              });
                            },
                          ),
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Column(
                      children: [
                        Text(entry.key.name, style: heading2),
                        Text(
                          '${_getSizeText(entry.key.isFootlong)} on ${entry.key.breadType.name} bread',
                          style: normalText,
                        ),
                        // Quantity controls: decrement, value, increment, and remove
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              tooltip: 'Decrease quantity',
                              onPressed: () {
                                final prevQty = entry.value;
                                setState(() {
                                  widget.cart.remove(entry.key, quantity: 1);
                                });
                                if (prevQty > 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Quantity updated'),
                                      duration: Duration(milliseconds: 800),
                                    ),
                                  );
                                } else {
                                  // prevQty == 1 -> item removed
                                  final removed = entry.key;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${removed.name} removed'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          setState(() {
                                            widget.cart.add(
                                              removed,
                                              quantity: 1,
                                            );
                                          });
                                        },
                                      ),
                                      duration: const Duration(seconds: 5),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            const SizedBox(width: 8),
                            // Tapping quantity opens numeric input dialog
                            GestureDetector(
                              onTap: () async {
                                final result = await showDialog<int>(
                                  context: context,
                                  builder: (_) => QuantityInputDialog(
                                    initialQuantity: entry.value,
                                  ),
                                );
                                if (result != null && result != entry.value) {
                                  setState(() {
                                    if (result > entry.value) {
                                      widget.cart.add(
                                        entry.key,
                                        quantity: result - entry.value,
                                      );
                                    } else {
                                      widget.cart.remove(
                                        entry.key,
                                        quantity: entry.value - result,
                                      );
                                    }
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Qty: ${entry.value}',
                                  style: normalText,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Increase quantity',
                              onPressed: entry.value >= 99
                                  ? null
                                  : () {
                                      setState(() {
                                        widget.cart.add(entry.key, quantity: 1);
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Quantity updated'),
                                          duration: Duration(milliseconds: 800),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '£${_getItemPrice(entry.key, entry.value).toStringAsFixed(2)}',
                              style: normalText,
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Remove item',
                              onPressed: () {
                                final removed = entry.key;
                                final removedQty = entry.value;
                                setState(() {
                                  widget.cart.remove(
                                    removed,
                                    quantity: removedQty,
                                  );
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${removed.name} removed'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        setState(() {
                                          widget.cart.add(
                                            removed,
                                            quantity: removedQty,
                                          );
                                        });
                                      },
                                    ),
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
              Text(
                'Total: £${widget.cart.totalPrice.toStringAsFixed(2)}',
                style: heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              StyledButton(
                onPressed: _goBack,
                icon: Icons.arrow_back,
                label: 'Back to Order',
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
