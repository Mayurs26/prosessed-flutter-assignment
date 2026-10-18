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

  static const Color primary = Color(0xFF6638F0);
  static const Color background = Color(0xFFF8F6FF);
  static const Color textPrimary = Color(0xFF17152F);
  static const Color textSecondary = Color(0xFF77758D);

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
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Order Confirmation',
          style: TextStyle(
            color: textPrimary,
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
                Positioned(top: -50, right: -65, child: _decorationCircle(190)),
                Positioned(
                  bottom: 20,
                  left: -75,
                  child: _decorationCircle(180),
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
                              child: _successIllustration(),
                            ),
                            const SizedBox(height: 30),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8EF),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF1C9958),
                                    size: 16,
                                  ),
                                  SizedBox(width: 7),
                                  Text(
                                    'ORDER CONFIRMED',
                                    style: TextStyle(
                                      color: Color(0xFF16834A),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              'Order placed\nsuccessfully!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 31,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 15),

                            const Text(
                              'Thank you for shopping with ShopSphere. '
                              'Your order has been processed successfully.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 14,
                                height: 1.8,
                              ),
                            ),
                            const SizedBox(height: 30),

                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: const Color(0xFFEAE5F7),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primary.withValues(alpha: 0.05),
                                    blurRadius: 20,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: const Row(
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
                                            color: textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'We hope you love your purchase!',
                                          style: TextStyle(
                                            color: textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.favorite_rounded,
                                    color: Color(0xFFE99BCB),
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
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
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
                              child: const Text(
                                'Back to Home',
                                style: TextStyle(
                                  color: textSecondary,
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

  Widget _successIllustration() {
    return Container(
      width: 174,
      height: 174,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE7DEFF), Color(0xFFF6F2FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.10),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(37),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF28B86B),
            size: 83,
          ),
        ),
      ),
    );
  }

  Widget _decorationCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE3DAFF).withValues(alpha: 0.35),
      ),
    );
  }
}

class _InfoIcon extends StatelessWidget {
  const _InfoIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECFF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: const Color(0xFF6638F0), size: 23),
    );
  }
}
