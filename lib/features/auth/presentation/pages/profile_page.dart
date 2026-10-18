import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _purple = Color(0xFF5035FF);
  static const Color _deepPurple = Color(0xFF21165C);
  static const Color _background = Color(0xFFF7F6FC);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          context.go('/login');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
        }
      },
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return Scaffold(
            backgroundColor: _background,
            appBar: AppBar(
              title: const Text('My Profile'),
              backgroundColor: _background,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 88,
                      width: 88,
                      decoration: BoxDecoration(
                        color: _purple.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        size: 44,
                        color: _purple,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      state is AuthFailure
                          ? 'Session unavailable'
                          : 'Loading your profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state is AuthFailure
                          ? state.message
                          : 'Please wait while we prepare your account.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (state is AuthFailure)
                      FilledButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Go to Login'),
                      )
                    else
                      const CircularProgressIndicator(color: _purple),
                  ],
                ),
              ),
            ),
          );
        }

        final session = state.session;
        final displayName = session.fullName.trim().isNotEmpty
            ? session.fullName.trim()
            : session.username;

        return Scaffold(
          backgroundColor: _background,
          body: SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 62, 24, 76),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_deepPurple, _purple, Color(0xFF806AFF)],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(36),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 44,
                                  width: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'MY ACCOUNT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Log out',
                                  onPressed: state is AuthLoggingOut
                                      ? null
                                      : () => _confirmLogout(context),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.13,
                                    ),
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.logout_rounded),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),
                            const Text(
                              'Hello there,',
                              style: TextStyle(
                                color: Color(0xFFDCD5FF),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Your ShopSphere account, all in one place.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: -44,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: _background,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _deepPurple.withValues(alpha: 0.12),
                                  blurRadius: 22,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: const Color(0xFFE8E3FF),
                              child: ClipOval(
                                child: session.image.isNotEmpty
                                    ? Image.network(
                                        session.image,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => const Icon(
                                          Icons.person_rounded,
                                          size: 48,
                                          color: _purple,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        size: 48,
                                        color: _purple,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 62, 20, 28),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Center(
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _deepPurple,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE6FF),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '@${session.username}',
                            style: const TextStyle(
                              color: _purple,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      const _SectionHeading(
                        title: 'Personal information',
                        subtitle: 'Your account details',
                      ),
                      const SizedBox(height: 15),

                      _ProfileInfoTile(
                        icon: Icons.email_outlined,
                        label: 'Email address',
                        value: session.email.isNotEmpty
                            ? session.email
                            : 'Not provided',
                        iconColor: const Color(0xFF5035FF),
                      ),
                      _ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Phone number',
                        value: session.phone?.isNotEmpty == true
                            ? session.phone!
                            : 'Not provided',
                        iconColor: const Color(0xFF00897B),
                      ),
                      _ProfileInfoTile(
                        icon: Icons.badge_outlined,
                        label: 'User ID',
                        value: session.id.toString(),
                        iconColor: const Color(0xFFE67E22),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: const Color(0xFFECE9F7)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 46,
                              width: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFFECE8FF),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.verified_user_outlined,
                                color: _purple,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Manage your ShopSphere session securely.',
                                    style: TextStyle(
                                      color: Color(0xFF77738A),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF239B70),
                              size: 22,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: state is AuthLoggingOut
                              ? null
                              : () => _confirmLogout(context),
                          icon: state is AuthLoggingOut
                              ? const SizedBox(
                                  height: 19,
                                  width: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded),
                          label: Text(
                            state is AuthLoggingOut
                                ? 'Logging out...'
                                : 'Log out',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: colors.error.withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          'SHOP SMART. LIVE BETTER.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant.withValues(
                              alpha: 0.65,
                            ),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.logout_rounded, color: _purple, size: 32),
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of ShopSphere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      context.read<AuthBloc>().add(const LogoutRequested());
    }
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF21165C),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF858197), fontSize: 13),
        ),
      ],
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE9F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF21165C).withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF858197),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF292442),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
