import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../models/product_category_model.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    required int limit,
    required int skip,
  });
  Future<List<ProductModel>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  });

  Future<List<ProductCategoryModel>> getCategories();

  Future<List<ProductModel>> getProductsByCategory({
    required String categorySlug,
    required int limit,
    required int skip,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl({required this._dio});

  final Dio _dio;

  @override
  Future<List<ProductModel>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.searchProducts,
      queryParameters: {'q': query, 'limit': limit, 'skip': skip},
    );

    final data = response.data;

    if (data == null || data['products'] is! List) {
      throw const FormatException('Invalid search response');
    }

    final productsJson = data['products'] as List<dynamic>;

    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductModel>> getProducts({
    required int limit,
    required int skip,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );

    final data = response.data;

    if (data == null || data['products'] is! List) {
      throw const FormatException('Invalid products response');
    }

    final productsJson = data['products'] as List<dynamic>;

    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<ProductCategoryModel>> getCategories() async {
    final response = await _dio.get<List<dynamic>>(
      ApiEndpoints.productCategories,
    );

    final data = response.data;

    if (data == null) {
      throw const FormatException('Invalid categories response');
    }

    return data
        .map(
          (json) => ProductCategoryModel.fromJson(json as Map<String, dynamic>),
        )
        .where((category) => category.slug.isNotEmpty)
        .toList();
  }

  @override
  Future<List<ProductModel>> getProductsByCategory({
    required String categorySlug,
    required int limit,
    required int skip,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiEndpoints.products}/category/$categorySlug',
      queryParameters: {'limit': limit, 'skip': skip},
    );

    final data = response.data;

    if (data == null || data['products'] is! List) {
      throw const FormatException('Invalid category products response');
    }

    final productsJson = data['products'] as List<dynamic>;

    return productsJson
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
