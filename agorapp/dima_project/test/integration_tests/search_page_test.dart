import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/events/event_tile.dart';
import 'package:dima_project/widgets/group_tile.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

// ignore: subtype_of_sealed_class
class MockQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Object> {
  final Map<String, dynamic> _data;

  MockQueryDocumentSnapshot(this._data);

  @override
  Map<String, dynamic> data() => _data;
}

void main() {
  late MockDatabaseService mockDatabaseService;
  late FirebaseFirestore fakeFirestore;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget createWidgetTest(bool isDarkMode, bool isTablet) {
    return ProviderScope(
      overrides: [
        followingProvider.overrideWith(
          (ref, uid) => Future.value([]),
        ),
        followingsStreamProvider.overrideWith(
          (ref, uid) => Stream.value([]),
        ),
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
      ],
      child: MediaQuery(
        data: MediaQueryData(
          platformBrightness: isDarkMode ? Brightness.dark : Brightness.light,
          size: isTablet ? const Size(1194.0, 834.0) : const Size(375.0, 812.0),
        ),
        child: CupertinoApp(
          home: SearchPage(
            databaseService: mockDatabaseService,
          ),
        ),
      ),
    );
  }

  group('SearchPage Tests', () {
    testWidgets('SearchPage has search field and options',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      await tester.pumpWidget(createWidgetTest(false, false));

      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(CupertinoSearchTextField), findsOneWidget);
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    });

    testWidgets(
        'Displays search for users when search field is empty for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, false));

      expect(find.text('Search for users'), findsOneWidget);
    });
    testWidgets(
        'Displays search for users when search field is empty for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, true));

      expect(find.text('Search for users'), findsOneWidget);
    });

    testWidgets(
        'Displays search for users when search field is empty in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, false));

      expect(find.text('Search for users'), findsOneWidget);
    });
    testWidgets(
        'Displays search for users when search field is empty in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, true));

      expect(find.text('Search for users'), findsOneWidget);
    });

    testWidgets(
        'SearchPage displays search for groups when search field is empty for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Search for groups'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for groups when search field is empty for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(false, true));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Search for groups'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for groups when search field is empty in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(true, false));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Search for groups'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for groups when search field is empty in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(true, true));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      expect(find.text('Search for groups'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for events when search field is empty for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Search for events'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for events when search field is empty for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(false, true));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Search for events'), findsOneWidget);
    });

    testWidgets(
        'SearchPage displays search for events when search field is empty in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(true, false));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Search for events'), findsOneWidget);
    });
    testWidgets(
        'SearchPage displays search for events when search field is empty in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      await tester.pumpWidget(createWidgetTest(true, true));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      expect(find.text('Search for events'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs user search and displays no results for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test user');
      await tester.pump();

      expect(find.text('No users found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs user search and displays no results for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');
      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, true));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test user');
      await tester.pump();

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs user search and displays no results in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, false));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test user');
      await tester.pump();

      expect(find.text('No users found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs user search and displays no results in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');
      when(mockDatabaseService.searchByUsernameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, true));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test user');
      await tester.pump();

      expect(find.text('No users found'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs groups search and displays no results for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByGroupNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test group');
      await tester.pump();

      expect(find.text('No groups found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs groups search and displays no results for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByGroupNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, true));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test group');
      await tester.pump();

      expect(find.text('No groups found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs groups search and displays no results in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByGroupNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, false));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test group');
      await tester.pump();

      expect(find.text('No groups found'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs groups search and displays no results in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByGroupNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, true));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test group');
      await tester.pump();

      expect(find.text('No groups found'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs events search and displays no results for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByEventNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test event');
      await tester.pump();

      expect(find.text('No events found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs events search and displays no results for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByEventNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(false, true));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test event');
      await tester.pump();

      expect(find.text('No events found'), findsOneWidget);
    });

    testWidgets(
        'SearchPage performs events search and displays no results in dark mode for phone',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByEventNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, false));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test event');
      await tester.pump();

      expect(find.text('No events found'), findsOneWidget);
    });
    testWidgets(
        'SearchPage performs events search and displays no results in dark mode for tablet',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1194.0, 834.0);
      tester.view.devicePixelRatio = 1.0;
      AuthService.setUid('testuid');

      when(mockDatabaseService.searchByEventNameStream(any))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createWidgetTest(true, true));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoSearchTextField), 'test event');
      await tester.pump();

      expect(find.text('No events found'), findsOneWidget);
    });
    testWidgets('SearchPage performs user search and displays results',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      const String usernameTest = 'username_test';

      await fakeFirestore.collection('users').doc('testuid').set({
        'name': 'name',
        'surname': 'surname',
        'username': usernameTest,
        'email': 'email',
        'imageUrl': '',
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'requests': ['request1', 'request2'],
        'token': 'token',
        'isSignedInWithGoogle': false,
        'groups': [],
      });

      when(mockDatabaseService.searchByUsernameStream(usernameTest))
          .thenAnswer((_) {
        final usersRef = fakeFirestore.collection('users');
        return usersRef.snapshots().map((snapshot) {
          return snapshot.docs.where((doc) {
            String username = (doc['username'] ?? '').toString().toLowerCase();
            return username.contains(usernameTest.toLowerCase());
          }).toList();
        });
      });

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), usernameTest);
      await tester.pumpAndSettle();

      expect(find.text('name surname'), findsOneWidget);
      expect(find.text(usernameTest), findsNWidgets(2));
      expect(find.byType(UserTile), findsOneWidget);
    });

    testWidgets('SearchPage performs user search and displays results',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      const String usernameTest = 'username_test';

      await fakeFirestore.collection('users').doc('testuid').set({
        'name': 'name',
        'surname': 'surname',
        'username': usernameTest,
        'email': 'email',
        'imageUrl': '',
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'requests': ['request1', 'request2'],
        'token': 'token',
        'isSignedInWithGoogle': false,
        'groups': [],
      });

      when(mockDatabaseService.searchByUsernameStream(usernameTest))
          .thenAnswer((_) {
        final usersRef = fakeFirestore.collection('users');
        return usersRef.snapshots().map((snapshot) {
          return snapshot.docs.where((doc) {
            String username = (doc['username'] ?? '').toString().toLowerCase();
            return username.contains(usernameTest.toLowerCase());
          }).toList();
        });
      });

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.enterText(
          find.byType(CupertinoSearchTextField), usernameTest);
      await tester.pumpAndSettle();

      expect(find.text('name surname'), findsOneWidget);
      expect(find.text(usernameTest), findsNWidgets(2));
      expect(find.byType(UserTile), findsOneWidget);
    });

    testWidgets('SearchPage performs group search and displays results',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      String groupName = 'group_name';
      await fakeFirestore.collection('groups').doc('id').set({
        'groupId': '123',
        'groupName': groupName,
        'description': 'description',
        'groupImage': '',
        'admin': 'admin',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'recentMessage': '',
        'members': ['admin'],
        'requests': [],
      });

      when(mockDatabaseService.searchByGroupNameStream(groupName))
          .thenAnswer((_) {
        final groupsRef = fakeFirestore.collection('groups');
        return groupsRef.snapshots().map((snapshot) {
          return snapshot.docs.where((doc) {
            String name = (doc['groupName'] ?? '').toString().toLowerCase();
            return name.contains(groupName.toLowerCase());
          }).toList();
        });
      });

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Groups'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoSearchTextField), groupName);
      await tester.pump();
      expect(find.text(groupName), findsNWidgets(2));
      expect(find.byType(GroupTile), findsOneWidget);
    });
    testWidgets('SearchPage performs event search and displays results',
        (WidgetTester tester) async {
      AuthService.setUid('testuid');
      String eventName = 'event_name';

      await fakeFirestore.collection('events').doc('eventId').set({
        'name': eventName,
        'description': 'description',
        'admin': 'admin',
        'imagePath': '',
        'isPublic': true,
        'createdAt': Timestamp.fromDate(DateTime(2021, 1, 1)),
        'eventId': 'eventId',
      });
      await fakeFirestore
          .collection('events')
          .doc('eventId')
          .collection('details')
          .add({
        'startDate': Timestamp.fromDate(DateTime(2021, 1, 1)),
        'endDate': Timestamp.fromDate(DateTime(2021, 1, 2)),
        'startTime': Timestamp.fromDate(DateTime(2021, 1, 1, 10, 0)),
        'endTime': Timestamp.fromDate(DateTime(2021, 1, 1, 12, 0)),
        'latlng': const GeoPoint(0, 0),
        'members': ['admin'],
        'requests': [],
        'location': 'location',
      });

      when(mockDatabaseService.searchByEventNameStream(eventName))
          .thenAnswer((_) {
        final eventsRef = fakeFirestore.collection('events');
        return eventsRef.snapshots().map((snapshot) {
          return snapshot.docs.where((doc) {
            String name = (doc['name'] ?? '').toString().toLowerCase();
            return name.contains(eventName.toLowerCase());
          }).toList();
        });
      });

      await tester.pumpWidget(createWidgetTest(false, false));
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoSearchTextField), eventName);
      await tester.pumpAndSettle();

      expect(find.byType(EventTile), findsOneWidget);
      expect(find.text('Description: description'), findsOneWidget);
      expect(find.text(eventName), findsNWidgets(2));
    });
  });
}
