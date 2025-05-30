import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:dima_project/services/auth_service.dart';

import '../../mocks/mock_auth_service.mocks.dart';
import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_news_service.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';

class MockUser extends Mock implements User {
  @override
  late final String uid;
  @override
  late final String email;
  MockUser(this.uid, this.email);
}

void main() {
  late TextEditingController usernameController;
  late TextEditingController passwordController;
  late AuthService mockAuthService;
  late MockDatabaseService mockDatabaseService;
  late MockNotificationService mockNotificationService;
  setUpAll(() {
    mockAuthService = MockAuthService();
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
  });

  setUp(() {
    usernameController = TextEditingController();
    passwordController = TextEditingController();
  });

  tearDown(() {
    usernameController.dispose();
    passwordController.dispose();
  });

  testWidgets('LoginForm renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    expect(find.byType(EmailInputField), findsOneWidget);
    expect(find.byType(PasswordInputField), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign In with Google'), findsOneWidget);
  });

  testWidgets('LoginForm shows validation errors', (WidgetTester tester) async {
    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
    expect(find.text('Please enter a password'), findsOneWidget);
  });

  testWidgets('LoginForm shows error dialog on login failure',
      (WidgetTester tester) async {
    // Mocking the signInWithEmailAndPassword method to throw an exception
    when(mockAuthService.signInWithEmailAndPassword(
            "not-exist@gmail.com", '123456'))
        .thenThrow(Exception("[ERROR 101] Invalid email or password"));

    await tester.pumpWidget(CupertinoApp(
      home: LoginForm(
        usernameController,
        passwordController,
        authService: mockAuthService,
        databaseService: mockDatabaseService,
      ),
    ));

    await tester.enterText(find.byType(EmailInputField), "not-exist@gmail.com");
    await tester.enterText(find.byType(PasswordInputField), '123456');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Login Failed'), findsOneWidget);
    expect(find.text('Failed to login: Invalid email or password'),
        findsOneWidget);
  });

  testWidgets('LoginForm calls signInWithGoogle on button tap',
      (WidgetTester tester) async {
    // Mocking the signInWithGoogle method to return a MockUser
    when(mockAuthService.signInWithGoogle())
        .thenAnswer((_) async => MockUser("test-uuid", "mail@mail.com"));
    when(mockDatabaseService.checkUserExist("mail@mail.com"))
        .thenAnswer((_) async => false);
    await tester.pumpWidget(CupertinoApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return LoginForm(
                  usernameController,
                  passwordController,
                  authService: mockAuthService,
                  databaseService: mockDatabaseService,
                );
              }),
          GoRoute(
              path: '/register',
              builder: (BuildContext context, GoRouterState state) {
                User? user = state.extra as User?;
                return RegisterPage(
                    user: user,
                    databaseService: mockDatabaseService,
                    authService: mockAuthService);
              }),
        ],
      ),
    ));
    await tester.tap(find.text('Sign In with Google'));
    await tester.pumpAndSettle();

    verify(mockAuthService.signInWithGoogle()).called(1);

    expect(find.byType(PersonalInformationForm), findsOneWidget);
  });
  testWidgets("Login with valid credentials", (WidgetTester tester) async {
    final MockNewsService mockNewsService = MockNewsService();
    when(mockAuthService.signInWithEmailAndPassword(
            'test@example.com', 'password123'))
        .thenAnswer(
            (_) async => Future.delayed(const Duration(milliseconds: 1)));
    when(mockNewsService.getNews()).thenAnswer((_) => Future.value());
    when(mockNewsService.getSliders()).thenAnswer((_) => Future.value());
    when(mockNotificationService.initialize(any, any, any, any))
        .thenAnswer((_) async => Future.value());
    when(mockNewsService.news).thenReturn([
      ArticleModel(
          title: 'title1',
          description: 'description1',
          url: 'url1',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title2',
          description: 'description2',
          url: 'url2',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title3',
          description: 'description3',
          url: 'url3',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title4',
          description: 'description4',
          url: 'url4',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title5',
          description: 'description5',
          url: 'url5',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title6',
          description: 'description6',
          url: 'url6',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title7',
          description: 'description7',
          url: 'url7',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title8',
          description: 'description8',
          url: 'url8',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title9',
          description: 'description9',
          url: 'url9',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title10',
          description: 'description10',
          url: 'url10',
          urlToImage: 'https://example.com/news.png'),
    ]);
    when(mockNewsService.sliders).thenReturn([
      ArticleModel(
          title: 'title1',
          description: 'description1',
          url: 'url1',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title2',
          description: 'description2',
          url: 'url2',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title3',
          description: 'description3',
          url: 'url3',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title4',
          description: 'description4',
          url: 'url4',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title5',
          description: 'description5',
          url: 'url5',
          urlToImage: 'https://example.com/news.png'),
      ArticleModel(
          title: 'title6',
          description: 'description6',
          url: 'url6',
          urlToImage: 'https://example.com/news.png'),
    ]);

    AuthService.setUid('test');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          userProvider.overrideWith(
            (ref, uid) => Future.value(UserData(
                uid: 'test',
                email: 'mail',
                username: 'username',
                imagePath: '',
                categories: [],
                name: 'name',
                surname: 'surname')),
          ),
          followingProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          groupsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          joinedEventsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          createdEventsProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
          followerProvider.overrideWith(
            (ref, uid) => Future.value([]),
          ),
        ],
        child: CupertinoApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) {
                    return LoginPage(
                      databaseService: mockDatabaseService,
                      authService: mockAuthService,
                    );
                  }),
              GoRoute(
                  path: '/home',
                  builder: (BuildContext context, GoRouterState state) {
                    return HomePage(
                      index: 0,
                      newsService: mockNewsService,
                      notificationService: mockNotificationService,
                    );
                  }),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(
        find.byType(CupertinoTextField).first, 'test@example.com');
    await tester.enterText(
        find.byType(CupertinoTextField).at(1), 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text("Trending News"), findsOneWidget);
    expect(find.text("Breaking News"), findsOneWidget);

    expect(find.text("title1"), findsNWidgets(2));
  });
}
