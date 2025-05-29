import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/pages/user_profile/user_profile_page.dart';
import 'package:dima_project/pages/user_profile/user_profile_tablet_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/events/event_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  group("User profile test for mobile in light mode", () {
    late final MockDatabaseService mockDatabaseService;
    late final MockNotificationService mockNotificationService;
    setUpAll(() {
      mockDatabaseService = MockDatabaseService();
      mockNotificationService = MockNotificationService();
    });
    testWidgets(
        "User profile of the current user renders correctly and navigations work for mobile layout",
        (WidgetTester tester) async {
      AuthService.setUid('test');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  uid: 'test',
                  email: 'mail',
                  username: 'username',
                  imagePath: '',
                  categories: ['Sports'],
                  name: 'name',
                  surname: 'surname')),
            ),
            followerProvider.overrideWith(
              (ref, uid) => Future.value([
                UserData(
                    uid: 'uid1',
                    email: 'mail1',
                    username: 'username1',
                    imagePath: '',
                    categories: ['Sports'],
                    name: 'name1',
                    surname: 'surname1')
              ]),
            ),
            followingProvider.overrideWith(
              (ref, uid) => Future.value([
                UserData(
                    uid: 'uid2',
                    email: 'mail2',
                    username: 'username2',
                    imagePath: '',
                    categories: ['Sports'],
                    name: 'name2',
                    surname: 'surname2')
              ]),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            groupsProvider.overrideWith(
              (ref, uid) => Future.value([
                Group(
                  name: "group name",
                  id: "id",
                  imagePath: '',
                  isPublic: true,
                  members: ['test'],
                )
              ]),
            ),
            joinedEventsProvider.overrideWith(
              (ref, id) => Future.value([
                Event(
                  id: '321',
                  imagePath: '',
                  admin: 'uid1',
                  name: 'event name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test', 'uid1'],
                        requests: [])
                  ],
                ),
              ]),
            ),
            createdEventsProvider.overrideWith(
              (ref, id) => Future.value([
                Event(
                  id: '123',
                  imagePath: '',
                  admin: 'test',
                  name: 'name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test'],
                        requests: [])
                  ],
                ),
              ]),
            ),
            eventProvider.overrideWith(
              (ref, id) => Future.value(
                Event(
                  id: '123',
                  imagePath: '',
                  admin: 'test',
                  name: 'name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test'],
                        requests: [])
                  ],
                ),
              ),
            ),
          ],
          child: CupertinoApp(
              home: ResponsiveLayout(
            mobileLayout: UserProfile(
              user: AuthService.uid,
            ),
            tabletLayout: UserProfileTablet(
              user: AuthService.uid,
            ),
          )),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("username"), findsOneWidget);
      expect(find.text("name surname"), findsOneWidget);
      expect(find.text("Followers"), findsOneWidget);
      expect(find.text("Following"), findsOneWidget);
      expect(find.text("Groups"), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text("Sports"), findsOneWidget);
      expect(find.text("Events created"), findsOneWidget);
      expect(find.text("Events joined"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.bars));
      await tester.pumpAndSettle();
      expect(find.text("Options"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text('username'), findsOneWidget);
      expect(find.text('name surname'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text("Events created"), findsOneWidget);
      expect(find.text("Events joined"), findsOneWidget);
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.text("group name"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No groups found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.text('username1'), findsOneWidget);
      expect(find.text('name1 surname1'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No followers found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Following"));
      await tester.pumpAndSettle();
      expect(find.text('username2'), findsOneWidget);
      expect(find.text('name2 surname2'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No following found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EventGrid));
      await tester.pumpAndSettle();
      expect(find.text('name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      await tester.tap(find.text("Go to Event"));
      await tester.pumpAndSettle();
      expect(find.text('name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Events joined"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EventGrid));
      await tester.pumpAndSettle();
      expect(find.text('event name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
    });
    testWidgets(
        "User profile of another user renders correctly and navigations work for mobile layout",
        (WidgetTester tester) async {
      AuthService.setUid('test');
      when(mockDatabaseService.getPrivateChatIdFromMembers(any))
          .thenAnswer((_) => Stream.value(null));
      when(mockDatabaseService.getPrivateChats(any))
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith((ref, uid) => Future.value(
                  UserData(
                      requests: [],
                      isPublic: false,
                      uid: 'uid1',
                      email: 'mail1',
                      username: 'username1',
                      imagePath: '',
                      categories: ['Sports'],
                      name: 'name1',
                      surname: 'surname1'),
                )),
            followerProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            followingProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            groupsProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            joinedEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
            createdEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
          ],
          child: const CupertinoApp(
              home: ResponsiveLayout(
            mobileLayout: UserProfile(
              user: 'uid1',
            ),
            tabletLayout: UserProfileTablet(
              user: 'uid1',
            ),
          )),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
      expect(find.text("name1 surname1"), findsOneWidget);
      expect(find.text("This Account is private"), findsOneWidget);
      expect(find.text("Follow"), findsOneWidget);
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.text("No groups"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.text("No followers"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Following"));
      await tester.pumpAndSettle();
      expect(find.text("No following anyone"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Follow"));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.envelope));
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
    });
    testWidgets(
        "UserProfile page prevents following a user who has deleted their account",
        (WidgetTester tester) async {
      AuthService.setUid('test');

      when(mockDatabaseService.toggleFollowUnfollow(any, any))
          .thenAnswer((_) => Future.error("User deleted his/her account"));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith((ref, uid) => Future.value(
                  UserData(
                      requests: [],
                      isPublic: false,
                      uid: 'uid1',
                      email: 'mail1',
                      username: 'username1',
                      imagePath: '',
                      categories: ['Sports'],
                      name: 'name1',
                      surname: 'surname1'),
                )),
            followerProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            followingProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            groupsProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            joinedEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
            createdEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
          ],
          child: const CupertinoApp(
              home: ResponsiveLayout(
            mobileLayout: UserProfile(
              user: 'uid1',
            ),
            tabletLayout: UserProfileTablet(
              user: 'uid1',
            ),
          )),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
      expect(find.text("name1 surname1"), findsOneWidget);
      expect(find.text("This Account is private"), findsOneWidget);
      expect(find.text("Follow"), findsOneWidget);

      await tester.tap(find.text("Follow"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("User deleted his/her account"), findsOneWidget);
      expect(find.text("Error"), findsOneWidget);
    });
  });

  group("User profile test for mobile in dark mode", () {
    late final MockDatabaseService mockDatabaseService;
    late final MockNotificationService mockNotificationService;
    setUpAll(() {
      mockDatabaseService = MockDatabaseService();
      mockNotificationService = MockNotificationService();
    });
    testWidgets(
        "User profile of the current user renders correctly and navigations work for mobile layout in dark mode",
        (WidgetTester tester) async {
      AuthService.setUid('test');
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith(
              (ref, uid) => Future.value(UserData(
                  uid: 'test',
                  email: 'mail',
                  username: 'username',
                  imagePath: '',
                  categories: ['Sports'],
                  name: 'name',
                  surname: 'surname')),
            ),
            followerProvider.overrideWith(
              (ref, uid) => Future.value([
                UserData(
                    uid: 'uid1',
                    email: 'mail1',
                    username: 'username1',
                    imagePath: '',
                    categories: ['Sports'],
                    name: 'name1',
                    surname: 'surname1')
              ]),
            ),
            followingProvider.overrideWith(
              (ref, uid) => Future.value([
                UserData(
                    uid: 'uid2',
                    email: 'mail2',
                    username: 'username2',
                    imagePath: '',
                    categories: ['Sports'],
                    name: 'name2',
                    surname: 'surname2')
              ]),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            groupsProvider.overrideWith(
              (ref, uid) => Future.value([
                Group(
                  name: "group name",
                  id: "id",
                  imagePath: '',
                  isPublic: true,
                  members: ['test'],
                )
              ]),
            ),
            joinedEventsProvider.overrideWith(
              (ref, id) => Future.value([
                Event(
                  id: '321',
                  imagePath: '',
                  admin: 'uid1',
                  name: 'event name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test', 'uid1'],
                        requests: [])
                  ],
                ),
              ]),
            ),
            createdEventsProvider.overrideWith(
              (ref, id) => Future.value([
                Event(
                  id: '123',
                  imagePath: '',
                  admin: 'test',
                  name: 'name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test'],
                        requests: [])
                  ],
                ),
              ]),
            ),
            eventProvider.overrideWith(
              (ref, id) => Future.value(
                Event(
                  id: '123',
                  imagePath: '',
                  admin: 'test',
                  name: 'name',
                  description: 'description',
                  isPublic: true,
                  details: [
                    EventDetails(
                        startDate: DateTime(2024, 3, 2, 1, 1, 1),
                        startTime: DateTime(2024, 3, 2, 1, 1, 1),
                        endDate: DateTime(2025, 3, 2, 1, 1, 1),
                        endTime: DateTime(2025, 3, 2, 1, 1, 1),
                        location: 'Location',
                        latlng: const LatLng(0, 0),
                        id: 'id',
                        members: ['test'],
                        requests: [])
                  ],
                ),
              ),
            ),
          ],
          child: MediaQuery(
            data: const MediaQueryData(platformBrightness: Brightness.dark),
            child: CupertinoApp(
                home: ResponsiveLayout(
              mobileLayout: UserProfile(
                user: AuthService.uid,
              ),
              tabletLayout: UserProfileTablet(
                user: AuthService.uid,
              ),
            )),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("username"), findsOneWidget);
      expect(find.text("name surname"), findsOneWidget);
      expect(find.text("Followers"), findsOneWidget);
      expect(find.text("Following"), findsOneWidget);
      expect(find.text("Groups"), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text("Events created"), findsOneWidget);
      expect(find.text("Events joined"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.bars));
      await tester.pumpAndSettle();
      expect(find.text("Options"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text('username'), findsOneWidget);
      expect(find.text('name surname'), findsOneWidget);
      expect(find.text('Followers'), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('1'), findsNWidgets(3));
      expect(find.text("Events created"), findsOneWidget);
      expect(find.text("Events joined"), findsOneWidget);
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.text("group name"), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No groups found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.text('username1'), findsOneWidget);
      expect(find.text('name1 surname1'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No followers found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Following"));
      await tester.pumpAndSettle();
      expect(find.text('username2'), findsOneWidget);
      expect(find.text('name2 surname2'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "ss");
      await tester.pumpAndSettle();
      expect(find.text('No following found'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EventGrid));
      await tester.pumpAndSettle();
      expect(find.text('name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      await tester.tap(find.text("Go to Event"));
      await tester.pumpAndSettle();
      expect(find.text('name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Events joined"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(EventGrid));
      await tester.pumpAndSettle();
      expect(find.text('event name'), findsOneWidget);
      expect(find.text('description'), findsOneWidget);
    });
    testWidgets(
        "User profile of another user renders correctly and navigations work for mobile layout in dark mode",
        (WidgetTester tester) async {
      AuthService.setUid('test');
      when(mockDatabaseService.getPrivateChatIdFromMembers(any))
          .thenAnswer((_) => Stream.value(null));
      when(mockDatabaseService.getPrivateChats(any))
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith((ref, uid) => Future.value(
                  UserData(
                      requests: [],
                      isPublic: false,
                      uid: 'uid1',
                      email: 'mail1',
                      username: 'username1',
                      imagePath: '',
                      categories: ['Sports'],
                      name: 'name1',
                      surname: 'surname1'),
                )),
            followerProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            followingProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            groupsProvider.overrideWith(
              (ref, uid) => Future.value([]),
            ),
            joinedEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
            createdEventsProvider.overrideWith(
              (ref, id) => Future.value([]),
            ),
          ],
          child: const MediaQuery(
            data: MediaQueryData(platformBrightness: Brightness.dark),
            child: CupertinoApp(
                home: ResponsiveLayout(
              mobileLayout: UserProfile(
                user: 'uid1',
              ),
              tabletLayout: UserProfileTablet(
                user: 'uid1',
              ),
            )),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
      expect(find.text("name1 surname1"), findsOneWidget);
      expect(find.text("This Account is private"), findsOneWidget);
      expect(find.text("Follow"), findsOneWidget);
      await tester.tap(find.text("Groups"));
      await tester.pumpAndSettle();
      expect(find.text("No groups"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.text("No followers"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Following"));
      await tester.pumpAndSettle();
      expect(find.text("No following anyone"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Follow"));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.envelope));
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
    });
  });
}
