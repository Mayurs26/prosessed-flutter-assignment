import 'package:get_it/get_it.dart';

import '../storage/token_storage.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  if (!getIt.isRegistered<TokenStorage>()) {
    getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());
  }
}
