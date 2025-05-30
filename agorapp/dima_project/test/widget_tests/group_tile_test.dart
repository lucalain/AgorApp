import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/group_tile.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  final Group testGroup = Group(
    id: '123',
    name: 'Group',
    imagePath: '',
    isPublic: true,
  );

  testWidgets('GroupTile displays group name and image',
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: GroupTile(group: testGroup, isJoined: 1),
          ),
        ),
      ),
    ));

    final nameFinder = find.text(testGroup.name);
    final imageFinder = find.byType(Image);

    expect(nameFinder, findsOneWidget);
    expect(imageFinder, findsOneWidget);
  });
  testWidgets("GroupTile shows GroupChatPage when group is joined and tapped",
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    final MockNotificationService mockNotificationService =
        MockNotificationService();
    when(mockDatabaseService.getChats(any)).thenAnswer((_) => Stream.value([]));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
        groupProvider.overrideWith(
          (ref, uid) => Future.value(testGroup),
        ),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: GroupTile(group: testGroup, isJoined: 1),
          ),
        ),
      ),
    ));
    expect(find.text("Joined"), findsOneWidget);
    await tester.tap(find.text('Group'));
    await tester.pumpAndSettle();
    expect(find.text("Group"), findsOneWidget);
  });
  testWidgets("GroupTile works correctly when join button is tapped",
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    final MockNotificationService mockNotificationService =
        MockNotificationService();
    when(mockDatabaseService.toggleGroupJoin(any)).thenAnswer((_) async {});

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: GroupTile(group: testGroup, isJoined: 0),
          ),
        ),
      ),
    ));
    expect(find.text("Join"), findsOneWidget);
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    verify(mockDatabaseService.toggleGroupJoin(testGroup.id)).called(1);
  });
  testWidgets("GroupTile prevents joining a non-existent group",
      (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.toggleGroupJoin(any)).thenAnswer((_) async {
      throw Exception();
    });

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseServiceProvider.overrideWithValue(mockDatabaseService),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: Center(
            child: GroupTile(group: testGroup, isJoined: 0),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('Join'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsOneWidget);
    expect(find.text("Failed to Join Group"), findsOneWidget);
    expect(find.text("Unable to join group as it has been deleted."),
        findsOneWidget);

    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoAlertDialog), findsNothing);
  });
}
