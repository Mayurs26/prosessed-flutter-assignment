import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/cart_item.dart';

abstract class CartRemoteDataSource {
  Future<Map<String, dynamic>> checkout({
    required int userId,
    required List<CartItem> items,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  CartRemoteDataSourceImpl({required this._dio});

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> checkout({
    required int userId,
    required List<CartItem> items,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.addCart,
      data: {
        'userId': userId,
        'products': items
            .map((item) => {'id': item.product.id, 'quantity': item.quantity})
            .toList(),
      },
    );

    final data = response.data;

    if (data == null || data['id'] == null) {
      throw const FormatException('Invalid checkout response');
    }

    return data;
  }
}
