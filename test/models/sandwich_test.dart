import 'package:flutter_test/flutter_test.dart';
import 'package:sandwich_shop/models/sandwich.dart';

void main() {
  group('Sandwich model', () {
    test('name returns readable name for each SandwichType', () {
      expect(
        Sandwich(
          type: SandwichType.veggieDelight,
          isFootlong: true,
          breadType: BreadType.white,
        ).name,
        'Veggie Delight',
      );

      expect(
        Sandwich(
          type: SandwichType.chickenTeriyaki,
          isFootlong: true,
          breadType: BreadType.white,
        ).name,
        'Chicken Teriyaki',
      );

      expect(
        Sandwich(
          type: SandwichType.tunaMelt,
          isFootlong: true,
          breadType: BreadType.white,
        ).name,
        'Tuna Melt',
      );

      expect(
        Sandwich(
          type: SandwichType.meatballMarinara,
          isFootlong: true,
          breadType: BreadType.white,
        ).name,
        'Meatball Marinara',
      );
    });

    test('image returns correct path for footlong and six_inch', () {
      final s1 = Sandwich(
        type: SandwichType.chickenTeriyaki,
        isFootlong: true,
        breadType: BreadType.wheat,
      );
      expect(
        s1.image,
        'assets/images/${SandwichType.chickenTeriyaki.name}_footlong.png',
      );

      final s2 = Sandwich(
        type: SandwichType.tunaMelt,
        isFootlong: false,
        breadType: BreadType.wheat,
      );
      expect(
        s2.image,
        'assets/images/${SandwichType.tunaMelt.name}_six_inch.png',
      );
    });

    test('image uses enum name substring (checks formatting)', () {
      final s = Sandwich(
        type: SandwichType.meatballMarinara,
        isFootlong: false,
        breadType: BreadType.white,
      );
      expect(s.image.contains(SandwichType.meatballMarinara.name), isTrue);
      expect(s.image.endsWith('_six_inch.png'), isTrue);
    });
  });
}
