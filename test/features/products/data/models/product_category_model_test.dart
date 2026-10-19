import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_category_model.dart';

void main() {
  group('ProductCategoryModel.fromJson', () {
    test('parses slug and name', () {
      final model = ProductCategoryModel.fromJson({
        'slug': 'smartphones',
        'name': 'Smartphones',
      });

      expect(model.slug, 'smartphones');
      expect(model.name, 'Smartphones');
    });

    test('uses empty defaults when fields are missing', () {
      final model = ProductCategoryModel.fromJson({});

      expect(model.slug, '');
      expect(model.name, '');
    });
  });
}
