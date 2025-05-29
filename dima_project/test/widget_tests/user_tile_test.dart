import 'package:dima_project/pages/user_profile/user_profile_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  final MockDatabaseService mockDatabaseService = MockDatabaseService();
  final UserData testUser = UserData(
    categories: ['test_category'],
    email: '',
    uid: 'test_user',
    username: 'test_username',
    name: 'Test',
    surname: 'User',
    imagePath: '',
    requests: [],
    isPublic: true,
  );

  Widget createWidgetForTesting({required Widget child}) {
    return ProviderScope(
      overrides: [
        groupsProvider.overrideWith((ref, uid) => Future.value([])),
        userProvider.overrideWith((ref, uid) => Future.value(testUser)),
        followerProvider.overrideWith((ref, uid) => Future.value([])),
        followingProvider.overrideWith((ref, uid) => Future.value([])),
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
        joinedEventsProvider.overrideWith((ref, uid) => Future.value([])),
        createdEventsProvider.overrideWith((ref, uid) => Future.value([])),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(child: child),
        ),
      ),
    );
  }

  testWidgets('UserTile displays user information',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');
    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 0),
    ));

    expect(find.text(testUser.username), findsOneWidget);
    expect(find.text('${testUser.name} ${testUser.surname}'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('UserTile shows unfollow button when following',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');

    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 1),
    ));
    expect(find.text('Unfollow'), findsOneWidget);
  });

  testWidgets('UserTile displays User Profile Page when tapped',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');

    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 0),
    ));
    await tester.tap(find.text("test_username"));
    await tester.pumpAndSettle();
    expect(find.byType(UserProfile), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
  });

  testWidgets('UserTile button changes to follow when unfollowing',
      (WidgetTester tester) async {
    AuthService.setUid('user_id');
    when(mockDatabaseService.toggleFollowUnfollow(any, any))
        .thenAnswer((_) async {});

    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 1),
    ));
    await tester.tap(find.text('Unfollow'));
    await tester.pumpAndSettle();
    verify(mockDatabaseService.toggleFollowUnfollow('test_user', 'user_id'))
        .called(1);
  });
  testWidgets("UserTile prevents following a non-existent user",
      (WidgetTester tester) async {
    AuthService.setUid('user_id');
    when(mockDatabaseService.toggleFollowUnfollow(any, any))
        .thenAnswer((_) async {
      throw Exception();
    });

    await tester.pumpWidget(createWidgetForTesting(
      child: UserTile(user: testUser, isFollowing: 0),
    ));
    await tester.tap(find.text('Follow'));
    await tester.pumpAndSettle();
    verify(mockDatabaseService.toggleFollowUnfollow('test_user', 'user_id'))
        .called(1);
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text('Failed to follow the user'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });
}
