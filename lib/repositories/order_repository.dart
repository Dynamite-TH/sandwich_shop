class OrderRepository {
  int _quantity = 0;
  final int maxQuantity;

  OrderRepository({required this.maxQuantity});

  int get quantity => _quantity;

  bool get canIncrement => _quantity < maxQuantity;
  bool get canDecrement => _quantity > 0;

  void increment() {
    if (canIncrement) {
      _quantity++;
    }
  }

  void decrement() {
    if (canDecrement) {
      _quantity--;
    }
  }
}

class PricingRepository {
  final double sixInchPrice;
  final double footlongPrice;

  PricingRepository({this.sixInchPrice = 7.0, this.footlongPrice = 11});

  double calculatePrice(int quantity, bool isFootlong) {
    double basePrice = sixInchPrice;
    if (isFootlong) {
      basePrice = footlongPrice;
    }
    return basePrice * quantity;
  }
}