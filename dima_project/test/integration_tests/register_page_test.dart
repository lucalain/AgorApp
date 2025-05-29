import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_auth_service.mocks.dart';
import '../mocks/mock_database_service.mocks.dart';

void main() {
  late MockDatabaseService mockDatabaseService;
  late MockAuthService mockAuthService;
  setUp(() {
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthService();
  });

  testWidgets('Initial page shows Credentials Information',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    expect(find.text('Credentials Information'), findsOneWidget);
    expect(find.byType(CredentialsInformationForm), findsOneWidget);
  });

  testWidgets('Navigates to Personal Information form on next button press',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken("test@example.com"))
        .thenAnswer((_) async => Future.value(false));
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );

    // Fill in the credentials form and press next
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.byType(PersonalInformationForm), findsOneWidget);
  });

  testWidgets('Shows error dialog if email is already taken',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid choice'), findsOneWidget);
    expect(find.text('Email is already taken.'), findsOneWidget);
  });

  testWidgets(
      'Navigates back to credentials form from personal information form',
      (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(
      CupertinoApp(
        home: RegisterPage(
          user: null,
          databaseService: mockDatabaseService,
          authService: mockAuthService,
        ),
      ),
    );
    // Fill in the credentials form and press next
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CupertinoTextField).last, 'password123');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Navigate back
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();

    expect(find.text('Credentials Information'), findsOneWidget);
    expect(find.byType(CredentialsInformationForm), findsOneWidget);
  });
  testWidgets("Complete registration", (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => false);
    when(mockDatabaseService.isUsernameTaken('Username'))
        .thenAnswer((_) async => false);
    when(mockAuthService.registerUser(any, any)).thenAnswer(
        (_) async => Future.delayed(const Duration(microseconds: 1)));
    await tester.pumpWidget(
      CupertinoApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return RegisterPage(
                    user: null,
                    databaseService: mockDatabaseService,
                    authService: mockAuthService,
                  );
                }),
            GoRoute(
                path: '/login',
                builder: (BuildContext context, GoRouterState state) {
                  return LoginPage(
                    databaseService: mockDatabaseService,
                    authService: mockAuthService,
                  );
                }),
          ],
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField).first, 'Name');
    await tester.enterText(find.byType(CupertinoTextField).at(1), 'Surname');
    await tester.enterText(find.byType(CupertinoTextField).at(2), 'Username');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalInformationForm), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesForm), findsOneWidget);
    expect(find.text("Categories"), findsOneWidget);
    //scroll down
    await tester.fling(
        find.byType(CategoriesForm), const Offset(0, -400), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text("Invalid choice"), findsOneWidget);
    expect(find.text("Please select at least one category."), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoryUtil.categories[12]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginForm), findsOneWidget);
  });
  testWidgets("Complete registration", (WidgetTester tester) async {
    when(mockDatabaseService.isEmailTaken('test@example.com'))
        .thenAnswer((_) async => false);
    when(mockDatabaseService.isUsernameTaken('Username'))
        .thenAnswer((_) async => false);
    when(mockAuthService.registerUser(any, any)).thenThrow(Exception(
        "[ERROR 101] Failed to connect to the server. Please check your internet connection."));

    await tester.pumpWidget(
      CupertinoApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
                path: '/',
                builder: (BuildContext context, GoRouterState state) {
                  return RegisterPage(
                    user: null,
                    databaseService: mockDatabaseService,
                    authService: mockAuthService,
                  );
                }),
            GoRoute(
                path: '/login',
                builder: (BuildContext context, GoRouterState state) {
                  return LoginPage(
                    databaseService: mockDatabaseService,
                    authService: mockAuthService,
                  );
                }),
          ],
        ),
      ),
    );
    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField).first, 'Name');
    await tester.enterText(find.byType(CupertinoTextField).at(1), 'Surname');
    await tester.enterText(find.byType(CupertinoTextField).at(2), 'Username');
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(PersonalInformationForm), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesForm), findsOneWidget);
    expect(find.text("Categories"), findsOneWidget);
    //scroll down
    await tester.fling(
        find.byType(CategoriesForm), const Offset(0, -400), 1000);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text("Invalid choice"), findsOneWidget);
    expect(find.text("Please select at least one category."), findsOneWidget);
    expect(find.text("OK"), findsOneWidget);
    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CategoryUtil.categories[12]));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();
    expect(
        find.textContaining(
            'Registration failed: Failed to connect to the server. Please check your internet connection'),
        findsOneWidget);
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
  });
}
