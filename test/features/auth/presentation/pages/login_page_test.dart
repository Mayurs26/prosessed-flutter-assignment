import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_use_case.dart';
import 'package:shopsphere/features/auth/domain/usecases/logout_use_case.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_event.dart';
import 'package:shopsphere/features/auth/presentation/bloc/auth_state.dart';
import 'package:shopsphere/features/auth/presentation/pages/login_page.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc authBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    authBloc = MockAuthBloc();

    when(() => authBloc.state).thenReturn(const AuthInitial());

    whenListen(
      authBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthInitial(),
    );
  });

  Widget createWidget() {
    return MaterialApp(
      home: BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('shows login form', (tester) async {
    await tester.pumpWidget(createWidget());

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('shows validation errors when login fields are empty', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('shows username and password length validation errors', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextFormField).at(0), 'ab');
    await tester.enterText(find.byType(TextFormField).at(1), '123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Username must be at least 3 characters'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);

    verifyNever(() => authBloc.add(any()));
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(createWidget());

    EditableText passwordField() {
      return tester.widget<EditableText>(find.byType(EditableText).at(1));
    }

    expect(passwordField().obscureText, isTrue);

    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();

    expect(passwordField().obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);
  });

  testWidgets('submits trimmed username and password when valid', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    await tester.enterText(find.byType(TextFormField).at(0), ' testuser ');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    await tester.tap(find.text('Login'));
    await tester.pump();

    final captured = verify(() => authBloc.add(captureAny())).captured;

    expect(captured, hasLength(1));
    expect(captured.single, isA<LoginRequested>());

    final event = captured.single as LoginRequested;

    expect(event.username, 'testuser');
    expect(event.password, 'password123');
  });
}
