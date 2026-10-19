import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _floatController;
  late final AnimationController _orbitController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  static const Color _purple = Color(0xFF294B45);
  static const Color _ink = Color(0xFF172B2A);
  static const Color _muted = Color(0xFF77827A);
  static const Color _background = Color(0xFFF5F7F2);

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.1, 1, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.12, 1, curve: Curves.easeOutCubic),
          ),
        );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _entranceController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthBloc>().add(const SessionRestoreRequested());
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/products');
        } else if (state is AuthFailure) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 650;
              final heroSize = math.min(
                constraints.maxWidth * 0.70,
                compact ? 230.0 : 280.0,
              );

              return Stack(
                children: [
                  // Soft ambient background, not a full-screen purple gradient.
                  const Positioned(
                    top: -100,
                    right: -100,
                    child: _AmbientGlow(size: 290, color: Color(0xFFE8EDE3)),
                  ),
                  const Positioned(
                    bottom: -120,
                    left: -100,
                    child: _AmbientGlow(size: 300, color: Color(0xFFF0F3EC)),
                  ),

                  // Small moving decorative dots.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _orbitController,
                        builder: (context, child) {
                          return CustomPaint(
                            painter: _AccentDots(
                              progress: _orbitController.value,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  Center(
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minimal wordmark.
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 37,
                                      width: 37,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8EDE3),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Image.asset(
                                        'assets/images/logo_bag.png',
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.shopping_bag_rounded,
                                          color: _purple,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    RichText(
                                      text: const TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Shop',
                                            style: TextStyle(
                                              color: _ink,
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.8,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Sphere',
                                            style: TextStyle(
                                              color: _purple,
                                              fontSize: 21,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: compact ? 24 : 42),

                            // Main visual: floating logo card with product accents.
                            SizedBox(
                              height: heroSize + 32,
                              width: double.infinity,
                              child: AnimatedBuilder(
                                animation: _floatController,
                                builder: (context, child) {
                                  final floatY =
                                      math.sin(
                                        _floatController.value * math.pi,
                                      ) *
                                      8;

                                  return Stack(
                                    alignment: Alignment.center,
                                    clipBehavior: Clip.none,
                                    children: [
                                      // Decorative rings.
                                      Container(
                                        width: heroSize * 0.94,
                                        height: heroSize * 0.94,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: const Color(0xFFDCE3D8),
                                            width: 1.2,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: heroSize * 0.72,
                                        height: heroSize * 0.72,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFFF0F3EC),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 8,
                                          ),
                                        ),
                                      ),

                                      Transform.translate(
                                        offset: Offset(0, floatY),
                                        child: ScaleTransition(
                                          scale: _scaleAnimation,
                                          child: Container(
                                            width: heroSize * 0.62,
                                            height: heroSize * 0.62,
                                            padding: const EdgeInsets.all(18),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              border: Border.all(
                                                color: const Color(0xFFDCE3D8),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF294B45)
                                                      .withValues(alpha: 0.12),
                                                  blurRadius: 36,
                                                  offset: const Offset(0, 18),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              'assets/images/logo_bag.png',
                                              fit: BoxFit.contain,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.shopping_bag_rounded,
                                                    size: 80,
                                                    color: _purple,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Floating category card.
                                      Positioned(
                                        left: 4,
                                        top: heroSize * 0.20,
                                        child: _FloatingTile(
                                          controller: _floatController,
                                          icon: Icons.headphones_rounded,
                                          background: const Color(0xFFE8EDE3),
                                          iconColor: const Color(0xFF365C37),
                                          delay: 0.4,
                                        ),
                                      ),

                                      Positioned(
                                        right: 3,
                                        top: heroSize * 0.12,
                                        child: _FloatingTile(
                                          controller: _floatController,
                                          icon: Icons.watch_rounded,
                                          background: const Color(0xFFF6E9D9),
                                          iconColor: const Color(0xFF9A6845),
                                          delay: 1.1,
                                        ),
                                      ),

                                      Positioned(
                                        right: heroSize * 0.05,
                                        bottom: heroSize * 0.02,
                                        child: _FloatingTile(
                                          controller: _floatController,
                                          icon: Icons.local_shipping_rounded,
                                          background: const Color(0xFFE8F2DF),
                                          iconColor: const Color(0xFF365C37),
                                          delay: 0.7,
                                        ),
                                      ),

                                      Positioned(
                                        left: heroSize * 0.12,
                                        bottom: heroSize * 0.02,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFDCE3D8),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: _ink.withValues(
                                                  alpha: 0.04,
                                                ),
                                                blurRadius: 14,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star_rounded,
                                                color: Color(0xFFF3B64B),
                                                size: 17,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                'Good finds',
                                                style: TextStyle(
                                                  color: _ink,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),

                            SizedBox(height: compact ? 20 : 32),

                            // Editorial headline.
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8EDE3),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 14,
                                            color: _purple,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'YOUR EVERYDAY MARKETPLACE',
                                            style: TextStyle(
                                              color: _purple,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 19),
                                    const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(text: 'Find what you '),
                                          TextSpan(
                                            text: 'love.',
                                            style: TextStyle(color: _purple),
                                          ),
                                        ],
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _ink,
                                        fontSize: 32,
                                        height: 1.15,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'A little something for every day.\nDiscover your next favourite.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _muted,
                                        fontSize: 14,
                                        height: 1.65,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: compact ? 26 : 38),

                            // Loading state.
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 170,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: const LinearProgressIndicator(
                                        minHeight: 4,
                                        backgroundColor: Color(0xFFDCE3D8),
                                        color: _purple,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  const Text(
                                    'GETTING THINGS READY',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: compact ? 14 : 24),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Small footer signature.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 12,
                    child: IgnorePointer(
                      child: Text(
                        'SHOP SMART  ·  LIVE BETTER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted.withValues(alpha: 0.75),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FloatingTile extends StatelessWidget {
  const _FloatingTile({
    required this.controller,
    required this.icon,
    required this.background,
    required this.iconColor,
    required this.delay,
  });

  final AnimationController controller;
  final IconData icon;
  final Color background;
  final Color iconColor;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final wave = math.sin((controller.value + delay * 0.15) * math.pi * 2);

        return Transform.translate(
          offset: Offset(0, wave * 6),
          child: Transform.rotate(angle: wave * 0.035, child: child),
        );
      },
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFDCE3D8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF294B45).withValues(alpha: 0.07),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
        ),
      ),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.60),
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccentDots extends CustomPainter {
  const _AccentDots({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const dots = [
      (x: 0.12, y: 0.19, radius: 2.0, phase: 0.0),
      (x: 0.88, y: 0.27, radius: 2.5, phase: 0.3),
      (x: 0.84, y: 0.70, radius: 1.8, phase: 0.6),
      (x: 0.10, y: 0.76, radius: 2.3, phase: 0.8),
      (x: 0.94, y: 0.48, radius: 1.5, phase: 0.4),
      (x: 0.24, y: 0.38, radius: 1.6, phase: 0.9),
      (x: 0.73, y: 0.87, radius: 2.0, phase: 0.2),
    ];

    for (final dot in dots) {
      final wave = math.sin((progress + dot.phase) * math.pi * 2);
      final x = size.width * dot.x;
      final y = size.height * dot.y + wave * 7;
      final opacity = 0.18 + ((wave + 1) / 2) * 0.25;

      paint.color = const Color(0xFF78958A).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), dot.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AccentDots oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
