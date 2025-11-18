import 'package:flutter/material.dart';

/// Dialog to input an exact integer quantity between 1 and [max].
class QuantityInputDialog extends StatefulWidget {
  final int initialQuantity;
  final int max;

  const QuantityInputDialog({super.key, required this.initialQuantity, this.max = 99});

  @override
  State<QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<QuantityInputDialog> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuantity.toString());
  }

  void _confirm() {
    final text = _controller.text.trim();
    final v = int.tryParse(text);
    if (v == null) {
      setState(() => _errorText = 'Please enter a valid number');
      return;
    }
    if (v < 1) {
      setState(() => _errorText = 'Minimum quantity is 1');
      return;
    }
    if (v > widget.max) {
      setState(() => _errorText = 'Maximum quantity is ${widget.max}');
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set quantity'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(errorText: _errorText),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _confirm, child: const Text('OK')),
      ],
    );
  }
}
