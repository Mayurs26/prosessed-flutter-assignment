import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/products/presentation/pages/product_listing_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/cart/presentation/pages/checkout_success_page.dart';
import 'main_navigation_shell.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/presentation/pages/product_details_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) => const SignupPage(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return MainNavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => const ProductListingPage(),
        ),
        GoRoute(
          path: '/product-details',
          builder: (context, state) {
            final product = state.extra! as Product;
            return ProductDetailsPage(product: product);
          },
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    ),
    GoRoute(
      path: '/checkout-success',
      name: 'checkout-success',
      builder: (context, state) => const CheckoutSuccessPage(),
    ),
  ],
);
