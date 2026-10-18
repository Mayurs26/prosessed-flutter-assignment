import 'package:dio/dio.dart';

import 'failure.dart';

class ExceptionMapper {
  ExceptionMapper._();

  static AppFailure fromDioException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          'The request took too long. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Unable to connect. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        return _mapStatusCode(exception.response?.statusCode);

      case DioExceptionType.cancel:
        return const UnknownFailure('The request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          'A secure connection could not be established.',
        );

      case DioExceptionType.unknown:
        return const UnknownFailure('Something went wrong. Please try again.');

      default:
        return const UnknownFailure(
          'An unexpected network error occurred. Please try again.',
        );
    }
  }

  static AppFailure _mapStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return const ValidationFailure(
          'Invalid request. Please check your input.',
        );

      case 401:
      case 403:
        return const UnauthorizedFailure(
          'Your session has expired. Please sign in again.',
        );

      case 404:
        return const NotFoundFailure('The requested resource was not found.');

      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerFailure(
          'The server is temporarily unavailable. Please retry.',
        );

      default:
        return const UnknownFailure(
          'An unexpected error occurred. Please try again.',
        );
    }
  }
}
