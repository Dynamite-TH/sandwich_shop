import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/repositories/order_repository.dart';

void main() {
  group('OrderRepository', () {
    test('initial quantity should be 0', () {
      final repository = OrderRepository(maxQuantity: 5);
      expect(repository.quantity, 0);
    });

    test('increment should increase quantity by 1', () {
      final repository = OrderRepository(maxQuantity: 5);
      repository.increment();
      expect(repository.quantity, 1);
    });

    test('decrement should decrease quantity by 1', () {
      final repository = OrderRepository(maxQuantity: 5);
      repository.increment(); // quantity is now 1
      repository.decrement(); // quantity is now 0
      expect(repository.quantity, 0);
    });

    test('quantity should not exceed maxQuantity', () {
      final repository = OrderRepository(maxQuantity: 2);
      repository.increment(); // quantity is 1
      repository.increment(); // quantity is 2
      repository.increment(); // should not change
      expect(repository.quantity, 2);
    });

    test('quantity should not go below 0', () {
      final repository = OrderRepository(maxQuantity: 5);
      repository.decrement(); // should not change
      expect(repository.quantity, 0);
    });
  });
  group('PricingRepository', () {
    test('calculates price for six-inch sandwiches', () {
      final pricing = PricingRepository(sixInchPrice: 7.0, footlongPrice: 11.0);
      final price = pricing.calculatePrice(3, false); // 3 six-inch sandwiches
      expect(price, 21.0);
    });

    test('calculates price for footlong sandwiches', () {
      final pricing = PricingRepository(sixInchPrice: 7.0, footlongPrice: 11.0);
      final price = pricing.calculatePrice(2, true); // 2 footlong sandwiches
      expect(price, 22.0);
    });
  });
}