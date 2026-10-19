import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_controller.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
            backgroundColor: colors.surface,
            appBar: AppBar(
              title: const Text(
                'My profile',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              backgroundColor: colors.surface,
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
                      decoration: BoxDecoration(
                        color: colors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        failed
                            ? Icons.person_off_outlined
                            : Icons.person_outline_rounded,
                        size: 40,
                        color: colors.primary,
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      failed
                          ? 'Session unavailable'
                          : 'Getting your profile ready',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onSurface,
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
                        color: colors.onSurfaceVariant,
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
                      CircularProgressIndicator(color: colors.primary),
                  ],
                ),
              ),
            ),
          );
        }

        final session = state.session;
        final isDarkTheme = theme.brightness == Brightness.dark;
        final profileCardColor = isDarkTheme
            ? const Color.fromARGB(255, 93, 78, 179)
            : colors.primary;
        final profileCardTextColor = isDarkTheme
            ? Colors.white
            : colors.onPrimary;
        final profileCardSecondaryColor = isDarkTheme
            ? const Color(0xFFE8E2FF)
            : const Color(0xFFD5E7A4);
        final profileCardDescriptionColor = isDarkTheme
            ? const Color(0xFFF3F0FF)
            : const Color(0xFFE0E8DF);
        final displayName = session.fullName.trim().isNotEmpty
            ? session.fullName.trim()
            : session.username;
        final loggingOut = state is AuthLoggingOut;

        return Scaffold(
          backgroundColor: colors.surface,
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
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            Icons.person_pin_rounded,
                            color: colors.onPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MY PROFILE',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: .3,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Your personal space',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
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
                            backgroundColor: colors.surfaceContainerLow,
                            foregroundColor: colors.primary,
                            side: BorderSide(color: colors.outlineVariant),
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
                          color: profileCardColor,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: .14),
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
                                    color: colors.onPrimary.withValues(
                                      alpha: .15,
                                    ),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: colors.onPrimary.withValues(
                                        alpha: .3,
                                      ),
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: colors.primaryContainer,
                                    child: ClipOval(
                                      child: session.image.isNotEmpty
                                          ? Image.network(
                                              session.image,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) => Icon(
                                                Icons.person_rounded,
                                                color: colors.primary,
                                                size: 35,
                                              ),
                                            )
                                          : Icon(
                                              Icons.person_rounded,
                                              color: colors.primary,
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
                                    color: colors.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        size: 14,
                                        color: colors.primary,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        'ACCOUNT',
                                        style: TextStyle(
                                          color: colors.primary,
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
                            Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                color: isDarkTheme
                                    ? const Color(0xFFE8E2FF)
                                    : const Color(0xFFC9D7CB),
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
                              style: TextStyle(
                                color: profileCardTextColor,
                                fontSize: 26,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '@${session.username}',
                              style: TextStyle(
                                color: profileCardSecondaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 1,
                              color: colors.onPrimary.withValues(alpha: .17),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  color: profileCardSecondaryColor,
                                  size: 17,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your account details are ready whenever you need them.',
                                    style: TextStyle(
                                      color: profileCardDescriptionColor,
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Personal details',
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Information linked to your account',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainer,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Icon(
                              Icons.tune_rounded,
                              color: colors.primary,
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
                        iconBg: colors.surfaceContainer,
                      ),
                      _DetailCard(
                        icon: Icons.call_outlined,
                        label: 'PHONE NUMBER',
                        value: session.phone?.isNotEmpty == true
                            ? session.phone!
                            : 'Not provided',
                        iconBg: colors.surfaceContainerHigh,
                      ),
                      _DetailCard(
                        icon: Icons.fingerprint_rounded,
                        label: 'USER ID',
                        value: session.id.toString(),
                        iconBg: colors.primaryContainer,
                      ),
                      const SizedBox(height: 20),

                      Builder(
                        builder: (context) {
                          final controller = ThemeControllerScope.of(context);
                          final isDark = controller.themeMode == ThemeMode.dark;
                          final colors = Theme.of(context).colorScheme;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: colors.outlineVariant),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(22),
                              clipBehavior: Clip.antiAlias,
                              child: SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                secondary: Icon(
                                  isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  color: colors.primary,
                                ),
                                title: Text(
                                  'Dark mode',
                                  style: TextStyle(
                                    color: colors.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                subtitle: Text(
                                  isDark
                                      ? 'Dark appearance enabled'
                                      : 'Light appearance enabled',
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                value: isDark,
                                onChanged: (enabled) {
                                  controller.setThemeMode(
                                    enabled ? ThemeMode.dark : ThemeMode.light,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainer,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.lock_outline_rounded,
                                color: colors.primary,
                              ),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Signed in securely',
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Your session is active on this device.',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle_rounded,
                              color: colors.primary,
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
                            backgroundColor: colors.surfaceContainerLow,
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
                      Center(
                        child: Text(
                          'SHOP SMART. LIVE BETTER.',
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: Icon(Icons.logout_rounded, color: colors.primary, size: 32),
        title: Text(
          'Log out?',
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of ShopSphere?',
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: colors.outlineVariant),
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
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  value,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
    );
  }
}
