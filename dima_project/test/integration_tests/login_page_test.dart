import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/pages/register_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_auth_service.mocks.dart';
import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_news_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

class MockUser extends Mock implements User {
  @override
  late final String uid;
  @override
  late final String email;
  MockUser(this.uid, this.email);
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  @override
  Future<void> sendPasswordResetEmail(
      {ActionCodeSettings? actionCodeSettings, required String email}) async {
    return;
  }
}

void main() {
  late final MockDatabaseService mockDatabaseService;
  late final MockAuthService mockAuthService;
  late final MockNewsService mockNewsService;
  late final MockNotificationService mockNotificationService;
  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthService();
    mockNewsService = MockNewsService();
    mockNotificationService = MockNotificationService();
  });

  group("Login Page Tests ", () {
    testWidgets(
        "Login and Forgot Password pages display correctly for smartphone",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: LoginPage(
            databaseService: mockDatabaseService,
            authService: mockAuthService,
          ),
        ),
      );

      expect(find.text('AGORAPP'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Password'), findsOneWidget);
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });
    testWidgets("Login and Forgot Password pages display correctly for tablet",
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
              size: Size(1194.0, 834.0), devicePixelRatio: 1.0),
          child: CupertinoApp(
            home: LoginPage(
              databaseService: mockDatabaseService,
              authService: mockAuthService,
            ),
          ),
        ),
      );

      expect(find.text('AGORAPP'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Sign In with Google'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();
      expect(find.text('Reset Password'), findsOneWidget);
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('LoginPage shows validation errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: LoginPage(
          authService: mockAuthService,
          databaseService: mockDatabaseService,
        ),
      ));

      await tester.tap(find.text('Login'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });
    testWidgets("Login with invalid credentials", (WidgetTester tester) async {
      when(mockAuthService.signInWithEmailAndPassword(any, any))
          .thenThrow(Exception("[ERROR 101] Invalid email or password"));
      await tester.pumpWidget(
        CupertinoApp(
          home: LoginPage(
            databaseService: mockDatabaseService,
            authService: mockAuthService,
          ),
        ),
      );
      await tester.enterText(
          find.byType(CupertinoTextField).first, 'test@example.com');
      await tester.enterText(
          find.byType(CupertinoTextField).at(1), 'password123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      expect(find.text('Login Failed'), findsOneWidget);
      expect(find.text('Failed to login: Invalid email or password'),
          findsOneWidget);
    });
    testWidgets("Login with valid credentials", (WidgetTester tester) async {
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
    testWidgets('LoginPage calls signInWithGoogle on button tap',
        (WidgetTester tester) async {
      // Mocking the signInWithGoogle method to return a MockUser
      when(mockAuthService.signInWithGoogle())
          .thenAnswer((_) async => MockUser("test-uuid", "mail@mail.com"));
      when(mockDatabaseService.checkUserExist("mail@mail.com"))
          .thenAnswer((_) async => false);
      when(mockDatabaseService.isEmailTaken('test@example.com'))
          .thenAnswer((_) async => false);
      when(mockDatabaseService.isUsernameTaken('Username'))
          .thenAnswer((_) async => true);
      when(mockDatabaseService.isUsernameTaken('valid'))
          .thenAnswer((_) async => false);
      when(mockDatabaseService.registerUserWithUUID(any, any, any))
          .thenAnswer((_) async => Future.value());
      when(mockNewsService.getSliders()).thenAnswer((_) => Future.value());
      when(mockNewsService.getNews()).thenAnswer((_) => Future.value());

      when(mockNotificationService.initialize(any, any, any, any))
          .thenAnswer((_) async => Future.value());
      when(mockAuthService.registerUser(any, any))
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

      await tester.pumpWidget(ProviderScope(
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
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
        child: CupertinoApp.router(
          routerConfig: GoRouter(
            routes: [
              GoRoute(
                  path: '/',
                  builder: (BuildContext context, GoRouterState state) {
                    return LoginPage(
                      authService: mockAuthService,
                      databaseService: mockDatabaseService,
                    );
                  }),
              GoRoute(
                  path: '/home',
                  builder: (BuildContext context, GoRouterState state) {
                    return HomePage(
                      newsService: mockNewsService,
                      notificationService: mockNotificationService,
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
        ),
      ));
      await tester.tap(find.text('Sign In with Google'));
      await tester.pumpAndSettle();

      verify(mockAuthService.signInWithGoogle()).called(1);

      expect(find.byType(PersonalInformationForm), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField).first, 'Name');
      await tester.enterText(find.byType(CupertinoTextField).at(1), 'Surname');
      await tester.enterText(find.byType(CupertinoTextField).at(2), 'Username');
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Invalid choice'), findsOneWidget);
      expect(find.text('Username is already taken.'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(2), 'valid');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));

      await tester.pumpAndSettle();
      expect(find.text('Profile Image'), findsOneWidget);

      expect(find.byType(Image), findsOneWidget);
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesForm), findsOneWidget);
      expect(find.text("Categories"), findsOneWidget);

      await tester.tap(find.text(CategoryUtil.categories[1]));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign in'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text("Trending News"), findsOneWidget);
      expect(find.text("Breaking News"), findsOneWidget);
      expect(find.text("title1"), findsNWidgets(2));
    });
  });
}
