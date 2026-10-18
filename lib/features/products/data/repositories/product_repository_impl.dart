import 'package:dio/dio.dart';

import '../../../../core/error/exception_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

import 'package:flutter/foundation.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required this._remoteDataSource});

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<List<Product>> getProducts({
    required int limit,
    required int skip,
  }) async {
    try {
      return await _remoteDataSource.getProducts(limit: limit, skip: skip);
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint('PRODUCT API ERROR TYPE: ${error.type}');
        debugPrint('PRODUCT API ERROR MESSAGE: ${error.message}');
        debugPrint('PRODUCT API ERROR DETAILS: ${error.error}');
        debugPrint('PRODUCT API REQUEST URL: ${error.requestOptions.uri}');
        debugPrint(
          'PRODUCT API RESPONSE STATUS: ${error.response?.statusCode}',
        );
      }

      throw ExceptionMapper.fromDioException(error);
    }
  }

  @override
  Future<List<Product>> searchProducts({
    required String query,
    required int limit,
    required int skip,
  }) async {
    try {
      return await _remoteDataSource.searchProducts(
        query: query,
        limit: limit,
        skip: skip,
      );
    } on DioException catch (error) {
      throw ExceptionMapper.fromDioException(error);
    } on FormatException {
      throw const ParsingFailure('Unable to process the search response.');
    }
  }

  @override
  Future<List<ProductCategory>> getCategories() async {
    try {
      final categories = await _remoteDataSource.getCategories();

      return categories
          .map(
            (category) =>
                ProductCategory(slug: category.slug, name: category.name),
          )
          .toList();
    } on DioException catch (error) {
      throw ExceptionMapper.fromDioException(error);
    } on FormatException {
      throw const ParsingFailure('Unable to process the categories response.');
    }
  }

  @override
  Future<List<Product>> getProductsByCategory({
    required String categorySlug,
    required int limit,
    required int skip,
  }) async {
    try {
      return await _remoteDataSource.getProductsByCategory(
        categorySlug: categorySlug,
        limit: limit,
        skip: skip,
      );
    } on DioException catch (error) {
      throw ExceptionMapper.fromDioException(error);
    } on FormatException {
      throw const ParsingFailure(
        'Unable to process the category products response.',
      );
    }
  }
}
