import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/core/error/exception_mapper.dart';
import 'package:shopsphere/core/error/failure.dart';

void main() {
  group('ExceptionMapper.fromDioException', () {
    DioException makeException({
      required DioExceptionType type,
      int? statusCode,
    }) {
      final requestOptions = RequestOptions(path: '/test');

      return DioException(
        requestOptions: requestOptions,
        type: type,
        response: statusCode == null
            ? null
            : Response(requestOptions: requestOptions, statusCode: statusCode),
      );
    }

    test('maps connection errors to NetworkFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.connectionError),
      );

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('internet connection'));
    });

    test('maps timeout errors to TimeoutFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.connectionTimeout),
      );

      expect(failure, isA<TimeoutFailure>());
      expect(failure.message, contains('too long'));
    });

    test('maps HTTP 400 to ValidationFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.badResponse, statusCode: 400),
      );

      expect(failure, isA<ValidationFailure>());
    });

    test('maps HTTP 401 and 403 to UnauthorizedFailure', () {
      for (final statusCode in [401, 403]) {
        final failure = ExceptionMapper.fromDioException(
          makeException(
            type: DioExceptionType.badResponse,
            statusCode: statusCode,
          ),
        );

        expect(failure, isA<UnauthorizedFailure>());
      }
    });

    test('maps HTTP 404 to NotFoundFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.badResponse, statusCode: 404),
      );

      expect(failure, isA<NotFoundFailure>());
    });

    test('maps HTTP 500, 502, 503 and 504 to ServerFailure', () {
      for (final statusCode in [500, 502, 503, 504]) {
        final failure = ExceptionMapper.fromDioException(
          makeException(
            type: DioExceptionType.badResponse,
            statusCode: statusCode,
          ),
        );

        expect(failure, isA<ServerFailure>());
      }
    });

    test('maps cancelled requests to UnknownFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.cancel),
      );

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('cancelled'));
    });

    test('maps unknown errors to UnknownFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.unknown),
      );

      expect(failure, isA<UnknownFailure>());
    });

    test('maps bad certificates to NetworkFailure', () {
      final failure = ExceptionMapper.fromDioException(
        makeException(type: DioExceptionType.badCertificate),
      );

      expect(failure, isA<NetworkFailure>());
    });
  });
}
