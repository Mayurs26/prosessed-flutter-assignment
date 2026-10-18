import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._preferences);

  final SharedPreferences _preferences;

  static const String _cartKey = 'shopsphere_cart_items';

  Future<void> saveCart(List<CartItem> items) async {
    final encodedItems = items.map((item) {
      return {
        'product': _productToJson(item.product),
        'quantity': item.quantity,
      };
    }).toList();

    await _preferences.setString(_cartKey, jsonEncode(encodedItems));
  }

  List<CartItem> getCart() {
    final savedCart = _preferences.getString(_cartKey);

    if (savedCart == null || savedCart.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(savedCart) as List<dynamic>;

      return decoded.map((item) {
        final data = item as Map<String, dynamic>;
        final productJson = data['product'] as Map<String, dynamic>;

        return CartItem(
          product: ProductModel.fromJson(productJson),
          quantity: (data['quantity'] as num).toInt(),
        );
      }).toList();
    } on FormatException {
      return const [];
    } on TypeError {
      return const [];
    }
  }

  Future<void> clearCart() async {
    await _preferences.remove(_cartKey);
  }

  Map<String, dynamic> _productToJson(Product product) {
    return {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'category': product.category,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'rating': product.rating,
      'stock': product.stock,
      'brand': product.brand,
      'thumbnail': product.thumbnail,
      'images': product.images,
      'reviews': product.reviews.map((review) {
        return {
          'rating': review.rating,
          'comment': review.comment,
          'date': review.date,
          'reviewerName': review.reviewerName,
          'reviewerEmail': review.reviewerEmail,
        };
      }).toList(),
    };
  }
}
