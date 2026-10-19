import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/network/api_endpoints.dart';

void main() {
  group('ApiEndpoints', () {
    test('defines the correct base URL', () {
      expect(ApiEndpoints.baseUrl, 'https://dummyjson.com');
    });

    test('defines authentication endpoints', () {
      expect(ApiEndpoints.login, '/auth/login');
      expect(ApiEndpoints.refreshToken, '/auth/refresh');
      expect(ApiEndpoints.currentUser, '/auth/me');
    });

    test('defines product endpoints', () {
      expect(ApiEndpoints.products, '/products');
      expect(ApiEndpoints.productCategories, '/products/categories');
      expect(ApiEndpoints.categoryList, '/products/category-list');
      expect(ApiEndpoints.searchProducts, '/products/search');
    });

    test('builds product detail URL', () {
      expect(ApiEndpoints.productDetails(42), '/products/42');
    });

    test('builds category URL', () {
      expect(
        ApiEndpoints.productsByCategory('smartphones'),
        '/products/category/smartphones',
      );
    });

    test('builds user cart URL', () {
      expect(ApiEndpoints.userCarts(7), '/carts/user/7');
    });

    test('defines add-cart endpoint', () {
      expect(ApiEndpoints.addCart, '/carts/add');
    });
  });
}
