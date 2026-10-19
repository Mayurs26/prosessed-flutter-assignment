import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson', () {
    test('parses a complete product including reviews', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'title': 'Phone',
        'description': 'Test phone',
        'category': 'smartphones',
        'price': 999.5,
        'discountPercentage': 10,
        'rating': 4.5,
        'stock': 12,
        'brand': 'TestBrand',
        'thumbnail': 'https://example.com/phone.png',
        'images': ['one.png', 'two.png', 123],
        'reviews': [
          {
            'rating': 5,
            'comment': 'Excellent',
            'date': '2026-01-01',
            'reviewerName': 'Alex',
            'reviewerEmail': 'alex@example.com',
          },
          'invalid-review-entry',
        ],
      });

      expect(model.id, 1);
      expect(model.title, 'Phone');
      expect(model.price, 999.5);
      expect(model.discountPercentage, 10);
      expect(model.rating, 4.5);
      expect(model.stock, 12);
      expect(model.brand, 'TestBrand');
      expect(model.images, ['one.png', 'two.png']);
      expect(model.reviews, hasLength(1));
      expect(model.reviews.first.comment, 'Excellent');
      expect(model.reviews.first.reviewerName, 'Alex');
    });

    test('uses defaults for missing optional fields', () {
      final model = ProductModel.fromJson({'id': 7});

      expect(model.id, 7);
      expect(model.title, '');
      expect(model.description, '');
      expect(model.category, '');
      expect(model.price, 0);
      expect(model.discountPercentage, 0);
      expect(model.rating, 0);
      expect(model.stock, 0);
      expect(model.brand, 'Unknown');
      expect(model.thumbnail, '');
      expect(model.images, isEmpty);
      expect(model.reviews, isEmpty);
    });

    test('converts numeric values to expected types', () {
      final model = ProductModel.fromJson({
        'id': 3.0,
        'title': 'Watch',
        'price': 120,
        'discountPercentage': 5,
        'rating': 4,
        'stock': 8.0,
      });

      expect(model.id, 3);
      expect(model.price, 120.0);
      expect(model.discountPercentage, 5.0);
      expect(model.rating, 4.0);
      expect(model.stock, 8);
    });

    test('uses defaults for missing review fields', () {
      final model = ProductModel.fromJson({
        'id': 1,
        'reviews': <Map<String, dynamic>>[{}],
      });

      expect(model.reviews, hasLength(1));
      expect(model.reviews.first.rating, 0);
      expect(model.reviews.first.comment, '');
      expect(model.reviews.first.date, '');
      expect(model.reviews.first.reviewerName, 'Anonymous');
      expect(model.reviews.first.reviewerEmail, '');
    });

    test('throws when required id is missing', () {
      expect(
        () => ProductModel.fromJson({'title': 'No ID'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
