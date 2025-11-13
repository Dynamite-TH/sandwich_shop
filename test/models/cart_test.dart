import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/cart.dart';
import 'package:sandwich_shop/models/sandwich.dart';
import 'package:sandwich_shop/repositories/pricing_repository.dart';

void main() {
  group('Cart model', () {
    late PricingRepository pricingRepo;
    late Cart cart;

    setUp(() {
      pricingRepo = PricingRepository(sixInchPrice: 7.0, footlongPrice: 11.0);
      cart = Cart(pricingRepo: pricingRepo, toastedFee: 0.25);
    });

    test('addItem merges identical items and increases quantity', () {
      final sandwich = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.wheat,
      );
      final itemA = OrderItem(
        sandwich: sandwich,
        quantity: 1,
        note: 'No onions',
        isToasted: false,
      );
      final itemB = OrderItem(
        sandwich: sandwich,
        quantity: 1,
        note: 'No onions',
        isToasted: false,
      );

      cart.addItem(itemA);
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 1);

      cart.addItem(itemB);
      // identical -> merged into single item with quantity 2
      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 2);
    });

    test('removeItemById removes the item', () {
      final sandwich = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.white,
      );
      final item = OrderItem(sandwich: sandwich, quantity: 1);
      cart.addItem(item);

      final id = cart.items.first.id;
      final removed = cart.removeItemById(id);
      expect(removed, isTrue);
      expect(cart.items, isEmpty);
    });

    test('decreaseQuantity reduces quantity and removes when zero', () {
      final sandwich = Sandwich(
        type: SandwichType.veggieDelight,
        isFootlong: true,
        breadType: BreadType.wholemeal,
      );
      final item = OrderItem(sandwich: sandwich, quantity: 2);
      cart.addItem(item);

      final id = cart.items.first.id;
      final first = cart.decreaseQuantity(id, amount: 1);
      expect(first, isTrue);
      expect(cart.items.first.quantity, 1);

      final second = cart.decreaseQuantity(id, amount: 1);
      expect(second, isTrue);
      expect(cart.items, isEmpty);
    });

    test('amendItem updates the item fields', () {
      final sandwich = Sandwich(
        type: SandwichType.meatballMarinara,
        isFootlong: false,
        breadType: BreadType.white,
      );
      final item = OrderItem(sandwich: sandwich, quantity: 1, note: 'Spicy');
      cart.addItem(item);

      final id = cart.items.first.id;
      final updated = cart.items.first.copyWith(note: 'No cheese', quantity: 3);
      final amended = cart.amendItem(id, updated);
      expect(amended, isTrue);
      final found = cart.findById(id)!;
      expect(found.note, 'No cheese');
      expect(found.quantity, 3);
    });

    test('totalPrice sums items and applies toastedFee', () {
      // one footlong toasted x2 (unit 11.0 + 0.25 = 11.25 => 22.5)
      final footlong = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.wheat,
      );
      final item1 = OrderItem(sandwich: footlong, quantity: 2, isToasted: true);
      cart.addItem(item1);

      // one six-inch not toasted x1 (unit 7.0 => 7.0)
      final six = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.white,
      );
      final item2 = OrderItem(sandwich: six, quantity: 1, isToasted: false);
      cart.addItem(item2);

      final total = cart.totalPrice;
      // expected 22.5 + 7.0 = 29.5
      expect(total, closeTo(29.5, 0.0001));
    });
  });
}
