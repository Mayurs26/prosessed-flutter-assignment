import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CheckoutSuccessPage extends StatefulWidget {
  const CheckoutSuccessPage({super.key});

  @override
  State<CheckoutSuccessPage> createState() => _CheckoutSuccessPageState();
}

class _CheckoutSuccessPageState extends State<CheckoutSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned(
                  top: -50,
                  right: -65,
                  child: _decorationCircle(context, 190),
                ),
                Positioned(
                  bottom: 20,
                  left: -75,
                  child: _decorationCircle(context, 180),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ScaleTransition(
                              scale: _scaleAnimation,
                              child: _successIllustration(context),
                            ),
                            const SizedBox(height: 30),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.tertiaryContainer,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: colors.onTertiaryContainer,
                                    size: 16,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'ORDER CONFIRMED',
                                    style: TextStyle(
                                      color: colors.onTertiaryContainer,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Order placed\nsuccessfully!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 31,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 15),

                            Text(
                              'Thank you for shopping with ShopSphere. '
                              'Your order has been processed successfully.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 14,
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: 30),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: colors.outlineVariant,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.shadow.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _InfoIcon(icon: Icons.verified_user_outlined),
                                  SizedBox(width: 13),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Thank you for your order',
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'We hope you love your purchase!',
                                          style: TextStyle(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: colors.tertiary,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: FilledButton.icon(
                                onPressed: () {
                                  context.go('/products');
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.onPrimary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(17),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 21,
                                ),
                                label: const Text(
                                  'Continue Shopping',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),

                            TextButton(
                              onPressed: () {
                                context.go('/products');
                              },
                              child: Text(
                                'Back to Home',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _successIllustration(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 174,
      height: 174,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primaryContainer, colors.surfaceContainerHigh],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.10),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(37),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.check_circle_rounded,
            color: colors.primary,
            size: 83,
          ),
        ),
      ),
    );
  }

  Widget _decorationCircle(BuildContext context, double size) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.primaryContainer.withValues(alpha: 0.24),
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: colors.primary, size: 23),
    );
  }
}
