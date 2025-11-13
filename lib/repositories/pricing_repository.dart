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
