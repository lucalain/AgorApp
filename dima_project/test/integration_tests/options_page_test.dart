import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/pages/options/options_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_auth_service.mocks.dart';
import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  late final MockDatabaseService mockDatabaseService;
  late final MockAuthService mockAuthService;
  late final MockNotificationService mockNotificationService;

  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
    mockAuthService = MockAuthService();
    mockNotificationService = MockNotificationService();
  });
  group("OptionsPage Tests", () {
    testWidgets('OptionsPage renders correctly and navigator works',
        (WidgetTester tester) async {
      AuthService.setUid('testUid');
      when(mockDatabaseService.acceptUserRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.denyUserRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.acceptUserGroupRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.denyUserGroupRequest(any))
          .thenAnswer((_) async => Future.value());
      when(mockDatabaseService.isUsernameTaken("test"))
          .thenAnswer((_) async => true);
      when(mockDatabaseService.isUsernameTaken("test_username"))
          .thenAnswer((_) async => false);
      when(mockDatabaseService.updateUserInformation(any, any, any, any))
          .thenAnswer((_) async => Future.value());

      when(mockDatabaseService.getFollowRequests('testUid'))
          .thenAnswer((_) async => [
                UserData(
                    categories: [],
                    email: "email",
                    name: "name",
                    surname: "surname",
                    username: "username",
                    imagePath: "",
                    isPublic: false,
                    uid: "uid"),
                UserData(
                    categories: [],
                    email: "email2",
                    name: "name2",
                    surname: "surname2",
                    username: "username2",
                    isPublic: false,
                    imagePath: "",
                    uid: "uid2")
              ]);
      when(mockDatabaseService.getUserGroupRequests('testUid'))
          .thenAnswer((_) async => [
                Group(
                    name: "name",
                    description: "description",
                    members: ["owner"],
                    admin: "owner",
                    id: "id",
                    categories: [],
                    imagePath: '',
                    isPublic: false),
                Group(
                    name: "name2",
                    description: "description2",
                    members: ["owner2"],
                    admin: "owner2",
                    id: "id2",
                    categories: [],
                    imagePath: '',
                    isPublic: false),
              ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: ['Culture'],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: CupertinoPageScaffold(
              child: OptionsPage(
                authService: mockAuthService,
                notificationService: mockNotificationService,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Options'), findsOneWidget);
      expect(find.byType(OptionTile), findsNWidgets(4));
      await tester.tap(find.byIcon(CupertinoIcons.square_list));
      await tester.pumpAndSettle();
      expect(find.text('Requests'), findsOneWidget); //Request page
      await tester.tap(find.byIcon(CupertinoIcons.person)); //Follow requests
      await tester.pumpAndSettle();
      expect(find.text('Follow Requests'), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      await tester.tap(find.text("Accept").first);
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsOneWidget);
      await tester.tap(find.text("Deny"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNothing);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byIcon(CupertinoIcons.person_2_square_stack)); //Group requests
      await tester.pumpAndSettle();
      expect(find.text('Group Requests'), findsOneWidget);
      expect(find.byType(CupertinoListTile), findsNWidgets(2));
      await tester.tap(find.text("Accept").first);
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsOneWidget);
      await tester.tap(find.text("Deny"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNothing);

      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.settings)); //Settings page
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.settings)); //Settings page
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField).at(2), '');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Please fill all the fields'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(2), 'test');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Username is already taken'), findsNothing);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(2), 'test_username');
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesForm), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Options'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
    });
    testWidgets("Test logout functionality", (WidgetTester tester) async {
      AuthService.setUid('test-uid');
      when(mockDatabaseService.updateToken(any))
          .thenAnswer((_) => Future.value());
      when(mockAuthService.signOut()).thenAnswer((_) => Future.value());
      when(mockNotificationService.unsubscribeAndClearTopics())
          .thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  isSignedInWithGoogle: false,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                    path: '/',
                    builder: (BuildContext context, GoRouterState state) {
                      return OptionsPage(
                        authService: mockAuthService,
                        notificationService: mockNotificationService,
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
        ),
      );
      await tester.tap(find.text("Exit"));
      await tester.pumpAndSettle();
      verify(mockAuthService.signOut()).called(1);
      expect(find.text("Login"), findsOneWidget);
    });
    testWidgets("Verifies account deletion when signed in with email",
        (WidgetTester tester) async {
      AuthService.setUid('test-uid');
      when(mockDatabaseService.updateToken(any))
          .thenAnswer((_) => Future.value());
      when(mockAuthService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockAuthService.reauthenticateUser(
              'test_email@mail.com', 'test_password'))
          .thenAnswer((_) => Future.value(true));
      when(mockAuthService.reauthenticateUser(
              'wrong_email@mail.com', 'wrong_password'))
          .thenAnswer((_) => Future.value(false));
      when(mockNotificationService.unsubscribeAndClearTopics())
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.updateToken(''))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockDatabaseService.getUserData(any)).thenAnswer((_) => Future.value(
          UserData(
              categories: [],
              email: "test_email",
              name: "test_name",
              surname: "test_surname",
              username: "test_username",
              isPublic: false,
              isSignedInWithGoogle: false,
              imagePath: "",
              uid: "testUid")));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  isSignedInWithGoogle: false,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                    path: '/',
                    builder: (BuildContext context, GoRouterState state) {
                      return OptionsPage(
                        authService: mockAuthService,
                        notificationService: mockNotificationService,
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
        ),
      );
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      expect(find.text("Confirm Account Deletion"), findsOneWidget);
      await tester.enterText(
          find.byType(CupertinoTextField).first, 'wrong_email@mail.com');
      await tester.enterText(
          find.byType(CupertinoTextField).last, 'wrong_password');
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("The email or password you entered is incorrect"),
          findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).first, 'test_email@mail.com');
      await tester.enterText(
          find.byType(CupertinoTextField).last, 'test_password');
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      verify(mockAuthService.deleteUser()).called(1);
      verify(mockDatabaseService.deleteUser()).called(1);
      expect(find.text("Login"), findsOneWidget);
    });
    testWidgets(
        "Verifies invalid account deletion attempt when signed in with Google",
        (WidgetTester tester) async {
      AuthService.setUid('test-uid');
      when(mockDatabaseService.updateToken(any))
          .thenAnswer((_) => Future.value());
      when(mockAuthService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockAuthService.reauthenticateUserWithGoogle())
          .thenAnswer((_) => Future.value(false));
      when(mockNotificationService.unsubscribeAndClearTopics())
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.updateToken(''))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockDatabaseService.getUserData(any)).thenAnswer((_) => Future.value(
          UserData(
              categories: [],
              email: "test_email",
              name: "test_name",
              surname: "test_surname",
              username: "test_username",
              isPublic: false,
              isSignedInWithGoogle: true,
              imagePath: "",
              uid: "testUid")));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  isSignedInWithGoogle: true,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                    path: '/',
                    builder: (BuildContext context, GoRouterState state) {
                      return OptionsPage(
                        authService: mockAuthService,
                        notificationService: mockNotificationService,
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
        ),
      );
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Delete Account"), findsNWidgets(2));
      expect(find.text("Are you sure you want to delete your account?"),
          findsOneWidget);

      await tester.tap(find.text("Yes"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Failed to reauthenticate with Google account"),
          findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      verifyNever(mockAuthService.deleteUser());
      verifyNever(mockDatabaseService.deleteUser());
    });
    testWidgets("Verifies account deletion when signed in with Google",
        (WidgetTester tester) async {
      AuthService.setUid('test-uid');
      when(mockDatabaseService.updateToken(any))
          .thenAnswer((_) => Future.value());
      when(mockAuthService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockAuthService.reauthenticateUserWithGoogle())
          .thenAnswer((_) => Future.value(true));
      when(mockNotificationService.unsubscribeAndClearTopics())
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.updateToken(''))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.deleteUser()).thenAnswer((_) => Future.value());
      when(mockDatabaseService.getUserData(any)).thenAnswer((_) => Future.value(
          UserData(
              categories: [],
              email: "test_email",
              name: "test_name",
              surname: "test_surname",
              username: "test_username",
              isPublic: false,
              isSignedInWithGoogle: true,
              imagePath: "",
              uid: "testUid")));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  isSignedInWithGoogle: true,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                    path: '/',
                    builder: (BuildContext context, GoRouterState state) {
                      return OptionsPage(
                        authService: mockAuthService,
                        notificationService: mockNotificationService,
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
        ),
      );
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Delete Account"), findsNWidgets(2));
      expect(find.text("Are you sure you want to delete your account?"),
          findsOneWidget);
      await tester.tap(find.text("No"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Delete Account"));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Yes"));
      await tester.pumpAndSettle();
      verify(mockAuthService.deleteUser()).called(1);
      verify(mockDatabaseService.deleteUser()).called(1);
      expect(find.text("Login"), findsOneWidget);
    });
    testWidgets(
        "Accept follow request of a deleted user and accept group request of a deleted group",
        (WidgetTester tester) async {
      AuthService.setUid('testUid');
      when(mockDatabaseService.acceptUserRequest(any)).thenAnswer((_) async {
        throw Exception("User not found");
      });
      when(mockDatabaseService.acceptUserGroupRequest(any))
          .thenAnswer((_) async {
        throw Exception("Group not found");
      });

      when(mockDatabaseService.getFollowRequests('testUid'))
          .thenAnswer((_) async => [
                UserData(
                    categories: [],
                    email: "email",
                    name: "name",
                    surname: "surname",
                    username: "username",
                    imagePath: "",
                    isPublic: false,
                    uid: "uid"),
              ]);
      when(mockDatabaseService.getUserGroupRequests('testUid'))
          .thenAnswer((_) async => [
                Group(
                    name: "name",
                    description: "description",
                    members: ["owner"],
                    admin: "owner",
                    id: "id",
                    categories: [],
                    imagePath: '',
                    isPublic: false),
              ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  categories: [],
                  email: "test_email",
                  name: "test_name",
                  surname: "test_surname",
                  username: "test_username",
                  isPublic: false,
                  imagePath: "",
                  uid: "testUid")),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: CupertinoPageScaffold(
              child: OptionsPage(
                authService: mockAuthService,
                notificationService: mockNotificationService,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Options'), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.square_list));
      await tester.pumpAndSettle();
      expect(find.text('Requests'), findsOneWidget); //Request page
      await tester.tap(find.byIcon(CupertinoIcons.person)); //Follow requests
      await tester.pumpAndSettle();
      await tester.tap(find.text("Accept"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("User deleted his account"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(
          find.byIcon(CupertinoIcons.person_2_square_stack)); //Group requests
      await tester.pumpAndSettle();
      await tester.tap(find.text("Accept"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Group has been deleted"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Requests'), findsOneWidget);
    });
  });
}
