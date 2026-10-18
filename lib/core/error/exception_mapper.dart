import 'package:dio/dio.dart';

import 'failure.dart';

class ExceptionMapper {
  ExceptionMapper._();

  static AppFailure fromDioException(DioException exception) {
    final type = exception.type;

    if (type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.sendTimeout ||
        type == DioExceptionType.receiveTimeout) {
      return const TimeoutFailure();
    }

    if (type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }

    if (type == DioExceptionType.badCertificate) {
      return const NetworkFailure(
        'A secure connection could not be established.',
      );
    }

    if (type == DioExceptionType.cancel) {
      return const UnknownFailure('The request was cancelled.');
    }

    if (type == DioExceptionType.badResponse) {
      return _mapStatusCode(exception.response?.statusCode);
    }

    return const UnknownFailure();
  }

  static AppFailure _mapStatusCode(int? statusCode) {
    if (statusCode == null) {
      return const UnknownFailure();
    }

    if (statusCode == 401) {
      return const ClientFailure(
        'Your session has expired. Please log in again.',
      );
    }

    if (statusCode == 404) {
      return const ClientFailure('The requested resource was not found.');
    }

    if (statusCode == 400) {
      return const ClientFailure(
        'The request was invalid. Please check your input.',
      );
    }

    if (statusCode >= 500) {
      return const ServerFailure();
    }

    if (statusCode >= 400) {
      return ClientFailure('Request failed (HTTP $statusCode).');
    }

    return const UnknownFailure();
  }
}
