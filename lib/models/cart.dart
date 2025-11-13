import 'package:flutter/foundation.dart';

import '../repositories/pricing_repository.dart';
import 'sandwich.dart';

// lightweight id generator (avoid extra package dependency)
int _nextIdCounter = 0;
String _generateId() =>
    'item_${DateTime.now().microsecondsSinceEpoch}_${_nextIdCounter++}';

/// A single item in the cart. Represents one or more identical sandwiches
/// (same size/bread/type) with an optional note and "toasted" flag.
class OrderItem {
  final String id;
  Sandwich sandwich;
  int quantity;
  String note;
  bool isToasted;

  OrderItem({
    String? id,
    required this.sandwich,
    this.quantity = 1,
    this.note = '',
    this.isToasted = false,
  }) : id = id ?? _generateId();

  /// Unit price computed using the provided [pricingRepo].
  /// This delegates base price computation to the repository so pricing
  /// rules live in one place. Small modifiers (e.g. toasted fee) can be
  /// applied here or added to the repository later.
  double unitPrice(PricingRepository pricingRepo, {double toastedFee = 0.0}) {
    // pricingRepo.calculatePrice expects quantity and size. We ask for 1.
    final base = pricingRepo.calculatePrice(1, sandwich.isFootlong);
    return base + (isToasted ? toastedFee : 0.0);
  }

  /// Total price for this OrderItem (unitPrice * quantity).
  double totalPrice(PricingRepository pricingRepo, {double toastedFee = 0.0}) {
    return unitPrice(pricingRepo, toastedFee: toastedFee) * quantity;
  }

  /// Create a copy with fields changed (useful for updates).
  OrderItem copyWith({
    String? id,
    Sandwich? sandwich,
    int? quantity,
    String? note,
    bool? isToasted,
  }) {
    return OrderItem(
      id: id ?? this.id,
      sandwich: sandwich ?? this.sandwich,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      isToasted: isToasted ?? this.isToasted,
    );
  }
}

/// Cart manages a list of [OrderItem]s and exposes convenience methods
/// for adding, removing and amending items. It uses [PricingRepository]
/// to compute prices and extends [ChangeNotifier] so UI code can listen
/// for changes.
class Cart extends ChangeNotifier {
  final PricingRepository pricingRepo;
  final double toastedFee;

  final List<OrderItem> _items = [];

  Cart({PricingRepository? pricingRepo, this.toastedFee = 0.25})
    : pricingRepo = pricingRepo ?? PricingRepository();

  List<OrderItem> get items => List.unmodifiable(_items);

  /// Add a new item to the cart. If an identical item (same sandwich and note and toasted)
  /// already exists we increase its quantity; otherwise a new item is pushed.
  void addItem(OrderItem item) {
    // try to find an identical existing item (same sandwich config and note/toasted)
    final index = _items.indexWhere((existing) {
      return existing.sandwich.type == item.sandwich.type &&
          existing.sandwich.isFootlong == item.sandwich.isFootlong &&
          existing.sandwich.breadType == item.sandwich.breadType &&
          existing.note == item.note &&
          existing.isToasted == item.isToasted;
    });

    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }

    notifyListeners();
  }

  /// Remove an item by id. Returns true if removed.
  bool removeItemById(String id) {
    final idx = _items.indexWhere((it) => it.id == id);
    if (idx < 0) return false;
    _items.removeAt(idx);
    notifyListeners();
    return true;
  }

  /// Decrease quantity for an item. If resulting quantity <= 0 the item is removed.
  bool decreaseQuantity(String id, {int amount = 1}) {
    final idx = _items.indexWhere((it) => it.id == id);
    if (idx < 0) return false;
    final current = _items[idx];
    final newQty = current.quantity - amount;
    if (newQty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = current.copyWith(quantity: newQty);
    }
    notifyListeners();
    return true;
  }

  /// Amend an existing item (replace with the provided updated item). The
  /// item's `id` is used to locate it. Returns true if amend succeeded.
  bool amendItem(String id, OrderItem updated) {
    final idx = _items.indexWhere((it) => it.id == id);
    if (idx < 0) return false;
    // keep the original id if caller didn't provide one
    _items[idx] = updated.copyWith(id: id);
    notifyListeners();
    return true;
  }

  /// Clear the cart
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Total price for the cart (sums each item's totalPrice). Uses the
  /// injected [PricingRepository] and cart-level toasted fee.
  double get totalPrice {
    return _items.fold(
      0.0,
      (sum, it) => sum + it.totalPrice(pricingRepo, toastedFee: toastedFee),
    );
  }

  /// Find an item by id
  OrderItem? findById(String id) {
    final idx = _items.indexWhere((it) => it.id == id);
    if (idx < 0) return null;
    return _items[idx];
  }
}
