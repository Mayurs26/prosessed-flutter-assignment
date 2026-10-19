import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:shopsphere/core/theme/theme_controller.dart';
import 'package:shopsphere/features/auth/domain/entities/auth_session.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_state.dart';
import 'package:shopsphere/features/auth/presentation/pages/profile_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc authBloc;
  late GoRouter router;
  late ThemeController themeController;

  final session = AuthSession(
    id: 42,
    username: 'mayur',
    email: 'mayur@example.com',
    firstName: 'Mayur',
    lastName: 'Sonawane',
    image: '',
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
  );

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    themeController = await ThemeController.create();

    authBloc = MockAuthBloc();

    when(() => authBloc.state).thenReturn(AuthSuccess(session));
    when(() => authBloc.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authBloc.close()).thenAnswer((_) async {});

    router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (context, state) => BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: const ProfilePage(),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen')),
        ),
      ],
    );
  });

  tearDown(() {
    router.dispose();
    authBloc.close();
    themeController.dispose();
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ThemeControllerScope(
        controller: themeController,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.pump();
  }

  testWidgets('shows profile identity and personal details', (tester) async {
    await pumpProfile(tester);

    expect(find.text('MY PROFILE'), findsOneWidget);
    expect(find.text('Your personal space'), findsOneWidget);
    expect(find.text('Mayur Sonawane'), findsOneWidget);
    expect(find.text('@mayur'), findsOneWidget);
    expect(find.text('mayur@example.com'), findsOneWidget);
    expect(find.text('USER ID'), findsOneWidget);
    expect(find.text('Signed in securely'), findsOneWidget);
    expect(find.text('Log out of ShopSphere'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('shows fallback text for missing email and phone', (
    tester,
  ) async {
    final incompleteSession = AuthSession(
      id: 7,
      username: 'guest',
      email: '',
      firstName: '',
      lastName: '',
      image: '',
      accessToken: 'test-access-token',
      refreshToken: 'test-refresh-token',
    );

    when(() => authBloc.state).thenReturn(AuthSuccess(incompleteSession));

    await pumpProfile(tester);

    expect(find.text('guest'), findsOneWidget);
    expect(find.text('Not provided'), findsNWidgets(2));
  });

  testWidgets('logout opens confirmation dialog', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byTooltip('Log out').first);
    await tester.pumpAndSettle();

    expect(find.text('Log out?'), findsOneWidget);
    expect(
      find.text('Are you sure you want to log out of ShopSphere?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('cancel keeps the user on profile', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byTooltip('Log out').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('MY PROFILE'), findsOneWidget);
    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('confirming logout dispatches LogoutRequested', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byTooltip('Log out').first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    verify(() => authBloc.add(any(that: isA<LogoutRequested>()))).called(1);
  });

  testWidgets('shows loading state when session is not ready', (tester) async {
    when(() => authBloc.state).thenReturn(AuthInitial());

    await pumpProfile(tester);

    expect(find.text('Getting your profile ready'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows failure state and login action', (tester) async {
    when(() => authBloc.state).thenReturn(const AuthFailure('Session expired'));

    await pumpProfile(tester);

    expect(find.text('Session unavailable'), findsOneWidget);
    expect(find.text('Session expired'), findsOneWidget);
    expect(find.text('Go to Login'), findsOneWidget);

    await tester.tap(find.text('Go to Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
  });
}
