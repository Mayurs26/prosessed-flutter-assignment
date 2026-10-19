import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';
import 'features/cart/presentation/bloc/checkout_bloc.dart';
import 'features/products/presentation/bloc/product_bloc.dart';

class ShopSphereApp extends StatefulWidget {
  const ShopSphereApp({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  State<ShopSphereApp> createState() => _ShopSphereAppState();
}

class _ShopSphereAppState extends State<ShopSphereApp> {
  @override
  void dispose() {
    widget.themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      controller: widget.themeController,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
          BlocProvider<ProductBloc>(create: (_) => getIt<ProductBloc>()),
          BlocProvider<CartBloc>(
            create: (_) => getIt<CartBloc>()..add(const CartLoaded()),
          ),
          BlocProvider<CheckoutBloc>(create: (_) => getIt<CheckoutBloc>()),
        ],
        child: AnimatedBuilder(
          animation: widget.themeController,
          builder: (context, _) {
            return MaterialApp.router(
              title: 'ShopSphere',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: widget.themeController.themeMode,
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
