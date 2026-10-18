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
  late final AnimationController _backgroundController;
  late final AnimationController _particleController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _contentSlide;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    )..repeat();

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.55,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0, 0.65, curve: Curves.easeIn),
    );

    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.24), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.25, 1, curve: Curves.easeOutCubic),
          ),
        );

    _glowAnimation = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
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
    _backgroundController.dispose();
    _particleController.dispose();
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF170D45),
                Color(0xFF3520A3),
                Color(0xFF6345FF),
                Color(0xFF24135D),
              ],
              stops: [0, 0.32, 0.68, 1],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Animated background glow.
              Positioned(
                top: -130,
                right: -100,
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    final movement = math.sin(
                      _backgroundController.value * math.pi * 2,
                    );

                    return Transform.translate(
                      offset: Offset(movement * 24, movement * 18),
                      child: child,
                    );
                  },
                  child: const _GlowOrb(size: 330, color: Color(0xFF9B8AFF)),
                ),
              ),
              Positioned(
                bottom: -140,
                left: -120,
                child: AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) {
                    final movement = math.cos(
                      _backgroundController.value * math.pi * 2,
                    );

                    return Transform.translate(
                      offset: Offset(movement * 20, -movement * 25),
                      child: child,
                    );
                  },
                  child: const _GlowOrb(size: 360, color: Color(0xFF7B61FF)),
                ),
              ),

              // Decorative floating particles.
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _ParticlePainter(
                          progress: _particleController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Main splash content.
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeTransition(
                            opacity: _logoFade,
                            child: ScaleTransition(
                              scale: _logoScale,
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      0,
                                      math.sin(
                                            _floatController.value * math.pi,
                                          ) *
                                          7,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB8A9FF)
                                                .withValues(
                                                  alpha:
                                                      0.12 *
                                                      _glowAnimation.value,
                                                ),
                                            blurRadius:
                                                45 * _glowAnimation.value,
                                            spreadRadius:
                                                8 * _glowAnimation.value,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(34),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.16,
                                        ),
                                        blurRadius: 30,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(23),
                                    child: Image.asset(
                                      'assets/images/logo_bag.png',
                                      width: 142,
                                      height: 142,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // Brand name and tagline enter from below.
                          SlideTransition(
                            position: _contentSlide,
                            child: FadeTransition(
                              opacity: _entranceController,
                              child: Column(
                                children: [
                                  const Text(
                                    'ShopSphere',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                      height: 1.15,
                                    ),
                                  ),
                                  const SizedBox(height: 13),
                                  Container(
                                    height: 3,
                                    width: 48,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFC8BBFF),
                                          Colors.white,
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Everything you love,\nin one place.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.84,
                                      ),
                                      fontSize: 16,
                                      height: 1.6,
                                      letterSpacing: 0.25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 54),

                          // Animated loading indicator.
                          FadeTransition(
                            opacity: _logoFade,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.7,
                                    strokeCap: StrokeCap.round,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.14,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'PREPARING YOUR EXPERIENCE',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.68),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom brand signature.
              Positioned(
                left: 0,
                right: 0,
                bottom: 22,
                child: SafeArea(
                  top: false,
                  child: Text(
                    'SHOP SMART. LIVE BETTER.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

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
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0.09),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  const _ParticlePainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const particles = [
      (x: 0.12, y: 0.20, radius: 2.0, phase: 0.0),
      (x: 0.83, y: 0.25, radius: 2.8, phase: 0.2),
      (x: 0.75, y: 0.66, radius: 1.8, phase: 0.4),
      (x: 0.18, y: 0.73, radius: 2.5, phase: 0.6),
      (x: 0.90, y: 0.48, radius: 1.7, phase: 0.8),
      (x: 0.36, y: 0.12, radius: 1.8, phase: 0.3),
      (x: 0.61, y: 0.84, radius: 2.2, phase: 0.7),
      (x: 0.08, y: 0.49, radius: 1.5, phase: 0.5),
      (x: 0.92, y: 0.78, radius: 2.0, phase: 0.1),
      (x: 0.45, y: 0.91, radius: 1.7, phase: 0.9),
    ];

    for (final particle in particles) {
      final wave = math.sin((progress + particle.phase) * math.pi * 2);

      final x = size.width * particle.x;
      final y = size.height * particle.y - wave * 10;
      final opacity = 0.25 + ((wave + 1) / 2) * 0.5;

      paint.color = Colors.white.withValues(alpha: opacity);

      canvas.drawCircle(Offset(x, y), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
