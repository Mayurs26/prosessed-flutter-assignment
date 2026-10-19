import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:shopsphere/features/cart/data/datasources/cart_remote_data_source.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item.dart';

class MockCartRemoteDataSource extends Mock implements CartRemoteDataSource {}

void main() {
  late MockCartRemoteDataSource remoteDataSource;
  late CartRepositoryImpl repository;

  setUp(() {
    remoteDataSource = MockCartRemoteDataSource();
    repository = CartRepositoryImpl(remoteDataSource: remoteDataSource);
  });

  test('returns checkout response on success', () async {
    final response = <String, dynamic>{
      'id': 123,
      'userId': 7,
      'products': <dynamic>[],
    };

    when(() => remoteDataSource.checkout(userId: 7, items: <CartItem>[]))
        .thenAnswer((_) async => response);

    final result = await repository.checkout(userId: 7, items: <CartItem>[]);

    expect(result, response);
    verify(() => remoteDataSource.checkout(userId: 7, items: <CartItem>[]))
        .called(1);
  });

  test('rethrows FormatException from remote data source', () async {
    when(() => remoteDataSource.checkout(userId: 7, items: <CartItem>[]))
        .thenThrow(const FormatException('Invalid checkout response'));

    await expectLater(
      repository.checkout(userId: 7, items: <CartItem>[]),
      throwsA(isA<FormatException>()),
    );
  });

  test('maps DioException to an application failure', () async {
    final dioException = DioException(
      requestOptions: RequestOptions(path: '/carts/add'),
      type: DioExceptionType.connectionError,
    );

    when(() => remoteDataSource.checkout(userId: 7, items: <CartItem>[]))
        .thenThrow(dioException);

    await expectLater(
      repository.checkout(userId: 7, items: <CartItem>[]),
      throwsA(isNot(isA<DioException>())),
    );
  });
}
