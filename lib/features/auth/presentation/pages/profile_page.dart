import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const Color _forest = Color(0xFF294B45);
  static const Color _ink = Color(0xFF172B2A);
  static const Color _sage = Color(0xFFE8EDE3);
  static const Color _canvas = Color(0xFFF5F7F2);
  static const Color _muted = Color(0xFF77827A);
  static const Color _line = Color(0xFFDCE3D8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) context.go('/login');
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
          final failed = state is AuthFailure;
          return Scaffold(
            backgroundColor: _canvas,
            appBar: AppBar(
              title: const Text(
                'My profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              backgroundColor: _canvas,
              surfaceTintColor: Colors.transparent,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 84,
                      width: 84,
                      decoration: const BoxDecoration(
                        color: _sage,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        failed
                            ? Icons.person_off_outlined
                            : Icons.person_outline_rounded,
                        size: 40,
                        color: _forest,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      failed
                          ? 'Session unavailable'
                          : 'Getting your profile ready',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: _ink,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      failed
                          ? state.message
                          : 'Just a moment while we load your account details.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (failed)
                      FilledButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.login_rounded),
                        label: const Text('Go to Login'),
                      )
                    else
                      const CircularProgressIndicator(color: _forest),
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
        final loggingOut = state is AuthLoggingOut;

        return Scaffold(
          backgroundColor: _canvas,
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _forest,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.person_pin_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MY PROFILE',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .3,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Your personal space',
                                style: TextStyle(color: _muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Log out',
                          onPressed: loggingOut
                              ? null
                              : () => _confirmLogout(context),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _forest,
                            side: const BorderSide(color: _line),
                          ),
                          icon: const Icon(Icons.logout_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // A compact identity card intentionally replaces the previous full-width gradient hero.
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _forest,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: _forest.withValues(alpha: .14),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: .3),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: _sage,
                                    child: ClipOval(
                                      child: session.image.isNotEmpty
                                          ? Image.network(
                                              session.image,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const Icon(
                                                    Icons.person_rounded,
                                                    color: _forest,
                                                    size: 35,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              color: _forest,
                                              size: 35,
                                            ),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD5E7A4),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: _forest,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'ACCOUNT',
                                        style: TextStyle(
                                          color: _forest,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                color: Color(0xFFC9D7CB),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '@${session.username}',
                              style: const TextStyle(
                                color: Color(0xFFD5E7A4),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: .17),
                            ),
                            const SizedBox(height: 14),
                            const Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: Color(0xFFD5E7A4),
                                  size: 17,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your account details are ready whenever you need them.',
                                    style: TextStyle(
                                      color: Color(0xFFE0E8DF),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal details',
                                  style: TextStyle(
                                    color: _ink,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Information linked to your account',
                                  style: TextStyle(color: _muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: _sage,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: _forest,
                              size: 19,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailCard(
                        icon: Icons.alternate_email_rounded,
                        label: 'EMAIL ADDRESS',
                        value: session.email.isNotEmpty
                            ? session.email
                            : 'Not provided',
                        iconBg: const Color(0xFFE5EDE0),
                      ),
                      _DetailCard(
                        icon: Icons.call_outlined,
                        label: 'PHONE NUMBER',
                        value: session.phone?.isNotEmpty == true
                            ? session.phone!
                            : 'Not provided',
                        iconBg: const Color(0xFFE8EFE8),
                      ),
                      _DetailCard(
                        icon: Icons.fingerprint_rounded,
                        label: 'USER ID',
                        value: session.id.toString(),
                        iconBg: const Color(0xFFF0F1E5),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8EDE3),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: _line),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.lock_outline_rounded,
                                color: _forest,
                              ),
                            ),
                            const SizedBox(width: 13),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Signed in securely',
                                    style: TextStyle(
                                      color: _ink,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your session is active on this device.',
                                    style: TextStyle(
                                      color: _muted,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.check_circle_rounded,
                              color: _forest,
                              size: 21,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: loggingOut
                              ? null
                              : () => _confirmLogout(context),
                          icon: loggingOut
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.logout_rounded),
                          label: Text(
                            loggingOut
                                ? 'Logging out...'
                                : 'Log out of ShopSphere',
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            backgroundColor: Colors.white,
                            side: BorderSide(
                              color: colors.error.withValues(alpha: .35),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'SHOP SMART. LIVE BETTER.',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w800,
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
        backgroundColor: _canvas,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.logout_rounded, color: _forest, size: 32),
        title: const Text(
          'Log out?',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w900),
        ),
        content: const Text('Are you sure you want to log out of ShopSphere?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF294B45),
              foregroundColor: Colors.white,
            ),
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

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconBg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDCE3D8)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: const Color(0xFF294B45), size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF77827A),
                    fontSize: 10,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF172B2A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9AA69B),
            size: 20,
          ),
        ],
      ),
    );
  }
}
