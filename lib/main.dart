import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();

  final themeController = await ThemeController.create();

  runApp(ShopSphereApp(themeController: themeController));
}
