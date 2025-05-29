import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/widgets/auth/forgot_password_widget.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_auth_service.mocks.dart';
import '../../mocks/mock_database_service.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late TextEditingController usernameController;

  setUp(() {
    mockAuthService = MockAuthService();
    usernameController = TextEditingController();
  });

  testWidgets('Displays success message when password reset email is sent',
      (WidgetTester tester) async {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
            path: '/',
            builder: (BuildContext context, GoRouterState state) {
              return ForgotPasswordForm(
                usernameController,
                authService: mockAuthService,
              );
            }),
        GoRoute(
            path: '/login',
            builder: (BuildContext context, GoRouterState state) {
              return LoginPage(
                databaseService: MockDatabaseService(),
                authService: mockAuthService,
              );
            }),
      ],
    );
    when(mockAuthService.sendPasswordResetEmail(any)).thenAnswer((_) async {});

    await tester.pumpWidget(
      CupertinoApp.router(
        routerConfig: router,
      ),
    );

    final emailField = find.byType(EmailInputField);
    await tester.enterText(emailField, 'test@example.com');

    final resetButton = find.text('Reset Password');
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('Success'), findsOneWidget);
    expect(
        find.text(
            'A password reset email has been sent to the email address provided.'),
        findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    verify(mockAuthService.sendPasswordResetEmail(any)).called(1);
  });

  testWidgets('Displays error message when password reset fails',
      (WidgetTester tester) async {
    when(mockAuthService.sendPasswordResetEmail(any)).thenThrow(Exception(
        "[ERROR 101] Failed to connect to the server. Please check your internet connection."));

    await tester.pumpWidget(
      CupertinoApp(
        home: ForgotPasswordForm(
          usernameController,
          authService: mockAuthService,
        ),
      ),
    );

    final emailField = find.byType(EmailInputField);
    await tester.enterText(emailField, 'test@example.com');

    final resetButton = find.text('Reset Password');
    await tester.tap(resetButton);
    await tester.pump();

    expect(find.text('Error'), findsOneWidget);
    expect(
        find.textContaining(
            'Failed to send password reset email: Failed to connect to the server. Please check your internet connection'),
        findsOneWidget);
  });
}
