import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../network/dio_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_use_case.dart';
import '../../features/products/presentation/bloc/product_bloc.dart';
import '../../features/products/domain/usecases/get_product_categories_use_case.dart';
import '../../features/products/domain/usecases/get_products_by_category_use_case.dart';
import '../../features/products/domain/usecases/search_products_use_case.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/cart/data/datasources/cart_local_data_source.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/cart/data/datasources/cart_remote_data_source.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/domain/repositories/cart_repository.dart';
import '../../features/cart/domain/usecases/checkout_use_case.dart';
import '../../features/cart/presentation/bloc/checkout_bloc.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/products/domain/usecases/get_product_by_id_use_case.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Local storage for cart persistence.
  final sharedPreferences = await SharedPreferences.getInstance();

  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSource(getIt<SharedPreferences>()),
  );

  getIt.registerFactory<CartBloc>(() => CartBloc(getIt<CartLocalDataSource>()));
  // Secure storage for authentication tokens.
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Token storage wrapper.
  getIt.registerLazySingleton<TokenStorage>(
    () => TokenStorage(getIt<FlutterSecureStorage>()),
  );

  // Shared Dio client for API requests.
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(tokenStorage: getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<Dio>(() => getIt<DioClient>().dio);

  // Authentication data source.
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<Dio>()),
  );

  // Authentication repository.
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // Login use case.
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
    ),
  );

  // Restore the current authenticated user.
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  // Logout and clear saved authentication tokens.
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  // Products data source.
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Products repository.
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt<ProductRemoteDataSource>(),
    ),
  );

  // Get products use case.
  getIt.registerLazySingleton<GetProductsUseCase>(
    () => GetProductsUseCase(getIt<ProductRepository>()),
  );
  getIt.registerLazySingleton<GetProductByIdUseCase>(
    () => GetProductByIdUseCase(getIt<ProductRepository>()),
  );

  getIt.registerLazySingleton<GetProductCategoriesUseCase>(
    () => GetProductCategoriesUseCase(getIt<ProductRepository>()),
  );

  // Products BLoC.
  getIt.registerFactory<ProductBloc>(
    () => ProductBloc(
      getProductsUseCase: getIt<GetProductsUseCase>(),
      getProductCategoriesUseCase: getIt<GetProductCategoriesUseCase>(),
      getProductsByCategoryUseCase: getIt<GetProductsByCategoryUseCase>(),
      searchProductsUseCase: getIt<SearchProductsUseCase>(),
    ),
  );

  getIt.registerLazySingleton<GetProductsByCategoryUseCase>(
    () => GetProductsByCategoryUseCase(getIt<ProductRepository>()),
  );

  getIt.registerLazySingleton<SearchProductsUseCase>(
    () => SearchProductsUseCase(getIt<ProductRepository>()),
  );

  // Cart checkout remote data source.
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  // Cart repository.
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(remoteDataSource: getIt<CartRemoteDataSource>()),
  );

  // Checkout use case.
  getIt.registerLazySingleton<CheckoutUseCase>(
    () => CheckoutUseCase(getIt<CartRepository>()),
  );

  // Checkout BLoC.
  getIt.registerFactory<CheckoutBloc>(
    () => CheckoutBloc(getIt<CheckoutUseCase>()),
  );
}
