import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/user_invitation_tile.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  final user = UserData(
    uid: '123',
    username: 'test_user',
    name: 'Test',
    surname: 'User',
    imagePath: '',
    categories: ['category'],
    email: 'email',
    requests: [],
    isPublic: true,
  );

  group('InvitationTile Tests', () {
    testWidgets('InvitationTile renders correctly when invited is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: UserInvitationTile(
            isFirst: false,
            isLast: false,
            user: user,
            invitePageKey: (uid) {},
            invited: false,
            isJoining: false,
          ),
        ),
      );

      expect(find.text('test_user'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Invite'), findsOneWidget);
    });

    testWidgets(
        'InvitationTile invites the user when the invite button is tapped',
        (WidgetTester tester) async {
      bool wasInvited = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: UserInvitationTile(
            isFirst: false,
            isLast: false,
            user: user,
            invitePageKey: (uid) {
              wasInvited = true;
            },
            invited: false,
            isJoining: false,
          ),
        ),
      );

      expect(find.text('Invite'), findsOneWidget);
      expect(wasInvited, isFalse);

      await tester.tap(find.text('Invite'));
      await tester.pump();

      expect(find.text('Invited'), findsOneWidget);
      expect(wasInvited, isTrue);
    });

    testWidgets(
        'InvitationTile does not show invite button when isJoining is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: UserInvitationTile(
            isFirst: false,
            isLast: false,
            user: user,
            invitePageKey: (uid) {},
            invited: false,
            isJoining: true,
          ),
        ),
      );

      expect(find.text('Invite'), findsNothing);
      expect(find.text('Invited'), findsNothing);
    });
    testWidgets(
        'When the InvitationTile is tapped, it navigates to and displays the User Profile page',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProvider.overrideWith((ref, uuid) => user),
            followerProvider.overrideWith((ref, uuid) => []),
            followingProvider.overrideWith((ref, uuid) => []),
            groupsProvider.overrideWith((ref, uuid) => []),
            joinedEventsProvider.overrideWith((ref, uuid) => []),
            createdEventsProvider.overrideWith((ref, uuid) => []),
            databaseServiceProvider
                .overrideWith((ref) => MockDatabaseService()),
            notificationServiceProvider
                .overrideWith((ref) => MockNotificationService()),
          ],
          child: CupertinoApp(
            home: UserInvitationTile(
              isFirst: false,
              isLast: false,
              user: user,
              invitePageKey: (uid) {},
              invited: false,
              isJoining: true,
            ),
          ),
        ),
      );
      expect(find.text('test_user'), findsOneWidget);
      await tester.tap(find.text('test_user'));
      await tester.pumpAndSettle();
      expect(find.text('test_user'), findsOneWidget);
      expect(find.text('Test User'), findsOneWidget);
    });
  });
}
