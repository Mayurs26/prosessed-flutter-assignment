import '../../../../core/error/exception_mapper.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

import 'package:dio/dio.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required this._remoteDataSource});

  final CartRemoteDataSource _remoteDataSource;

  @override
  Future<Map<String, dynamic>> checkout({
    required int userId,
    required List<CartItem> items,
  }) async {
    try {
      return await _remoteDataSource.checkout(userId: userId, items: items);
    } on DioException catch (error) {
      throw ExceptionMapper.fromDioException(error);
    } on FormatException {
      rethrow;
    }
  }
}
