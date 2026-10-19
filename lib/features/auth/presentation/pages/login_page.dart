import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  static const _purple = Color(0xFF294B45);
  static const _lavender = Color(0xFF86A85B);
  static const _ink = Color(0xFF172B2A);
  static const _muted = Color(0xFF77827A);
  static const _border = Color(0xFFDCE3D8);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      LoginRequested(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: Stack(
        children: [
          const Positioned(
            top: -110,
            right: -140,
            child: _BackgroundCircle(size: 390),
          ),
          const Positioned(
            bottom: -110,
            left: -80,
            child: _BackgroundCircle(size: 260),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;

                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 48 : 24,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1000),
                      child: isWide
                          ? _buildWideLayout(context)
                          : _buildMobileLayout(context),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/products');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBranding(context, isWide: false),
              const SizedBox(height: 42),
              Text(
                'Welcome back',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to pick up where your shopping left off',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),
              _buildUsernameField(state),
              const SizedBox(height: 16),
              _buildPasswordField(state),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: null,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: _purple, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildLoginButton(context, state),
              const SizedBox(height: 26),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/products');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.only(right: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBranding(context, isWide: true),
                      const SizedBox(height: 28),
                      Text(
                        'Thoughtful finds. Effortless shopping.',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: _muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Welcome back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to pick up where your shopping left off',
                      style: TextStyle(color: _muted),
                    ),
                    const SizedBox(height: 28),
                    _buildUsernameField(state),
                    const SizedBox(height: 16),
                    _buildPasswordField(state),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: null,
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLoginButton(context, state),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranding(BuildContext context, {required bool isWide}) {
    final logoSize = isWide ? 160.0 : 140.0;

    return Column(
      crossAxisAlignment: isWide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.start,
      children: [
        if (!isWide)
          SizedBox(
            height: 170,
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/images/shopping_sample.png',
                    width: 220,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: 155,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo_bag.png',
                          width: 125,
                          height: 125,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 0),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Shop',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                              TextSpan(
                                text: 'Sphere',
                                style: TextStyle(
                                  color: _purple,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Image.asset(
                'assets/images/logo_bag.png',
                width: logoSize,
                height: logoSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Image.asset(
                  'assets/images/shopping_sample.png',
                  height: 260,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        if (!isWide) const SizedBox(height: 0),
        if (!isWide)
          const Text(
            'Thoughtful finds. Effortless shopping.',
            style: TextStyle(color: _muted, fontSize: 13, height: 1.0),
          ),
      ],
    );
  }

  Widget _buildUsernameField(AuthState state) {
    return TextFormField(
      controller: _usernameController,
      enabled: state is! AuthLoading,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      style: const TextStyle(color: _ink, fontSize: 17),
      decoration: _inputDecoration(
        label: 'Username',
        hint: 'Enter your username',
        icon: Icons.person_outline_rounded,
      ),
      validator: (value) {
        final username = value?.trim() ?? '';

        if (username.isEmpty) {
          return 'Please enter your username';
        }

        if (username.length < 3) {
          return 'Username must be at least 3 characters';
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField(AuthState state) {
    return TextFormField(
      controller: _passwordController,
      enabled: state is! AuthLoading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      onFieldSubmitted: (_) {
        if (state is! AuthLoading) {
          _submitLogin(context);
        }
      },
      style: const TextStyle(color: _ink, fontSize: 17),
      decoration:
          _inputDecoration(
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
          ).copyWith(
            suffixIcon: IconButton(
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _muted,
                size: 24,
              ),
            ),
          ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }

        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _muted, size: 25),
      filled: true,
      fillColor: const Color(0xFFEEF2EA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 23),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: _purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(19),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, AuthState state) {
    final isLoading = state is AuthLoading;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_purple, _lavender]),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: _purple.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FilledButton(
        onPressed: isLoading ? null : () => _submitLogin(context),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          minimumSize: const Size.fromHeight(64),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Spacer(),
                  Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  const _BackgroundCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Color(0xFFDDE8D4), Color(0x00DDE8D4)],
          ),
        ),
      ),
    );
  }
}
