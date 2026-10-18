class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String currentUser = '/auth/me';

  static const String products = '/products';
  static const String productCategories = '/products/categories';
  static const String categoryList = '/products/category-list';
  static const String searchProducts = '/products/search';

  static const String addCart = '/carts/add';

  static String productDetails(int id) => '/products/$id';

  static String productsByCategory(String slug) => '/products/category/$slug';

  static String userCarts(int userId) => '/carts/user/$userId';
}
