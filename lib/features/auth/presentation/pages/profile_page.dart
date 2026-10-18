import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
        if (state is AuthInitial) {
          context.go('/login');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        if (state is! AuthSuccess) {
          return Scaffold(
            appBar: AppBar(title: const Text('My Profile')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Authentication state: ${state.runtimeType}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (state is AuthFailure)
                      Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final session = state.session;

        return Scaffold(
          appBar: AppBar(title: const Text('My Profile'), centerTitle: false),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              Center(
                child: CircleAvatar(
                  radius: 54,
                  backgroundColor: colors.primaryContainer,
                  child: ClipOval(
                    child: Image.network(
                      session.image,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.person_rounded,
                        size: 58,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                session.fullName.isEmpty ? session.username : session.fullName,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '@${session.username}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Personal Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ProfileInfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: session.email,
              ),
              _ProfileInfoTile(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: session.phone?.isNotEmpty == true
                    ? session.phone!
                    : 'Not provided',
              ),
              _ProfileInfoTile(
                icon: Icons.badge_outlined,
                label: 'User ID',
                value: session.id.toString(),
              ),
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: state is AuthLoggingOut
                    ? null
                    : () => _confirmLogout(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colors.error),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(label),
        subtitle: Text(value),
      ),
    );
  }
}
