import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/widgets/chats/group_chat_tile_tablet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets('GroupChatTileTablet displays group name when it is not selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: null);
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupChatTileTablet(
            selectedGroupId: '',
            databaseService: MockDatabaseService(),
            group: testGroup,
            onPressed: (Group group) {},
            username: "",
            onDismissed: (DismissDirection direction) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Test Group"), findsOneWidget);
    expect(find.text("Join the conversation!"), findsOneWidget);
  });
  testWidgets('GroupChatTileTablet displays group name when it is selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: null);
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupChatTileTablet(
            selectedGroupId: '1',
            databaseService: MockDatabaseService(),
            group: testGroup,
            onPressed: (Group group) {},
            username: "",
            onDismissed: (DismissDirection direction) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("Test Group"), findsOneWidget);
    expect(find.text("Join the conversation!"), findsOneWidget);
  });
  testWidgets(
      "GroupChatTileTablet correctly displays the latest message content and accurately reflects the count of unread messages",
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 1,
          sentByMe: false,
          recentMessageSender: 'User1',
        ));
    const String username = "User1";
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupChatTileTablet(
            databaseService: mockDatabaseService,
            selectedGroupId: '',
            group: testGroup,
            onPressed: (Group group) {},
            username: username,
            onDismissed: (DismissDirection direction) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text("Test Group"), findsOneWidget);
    expect(find.text("User1: Hello!"), findsOneWidget);

    expect(find.text("Join the conversation!"), findsNothing);
    expect(find.text("1"), findsOneWidget); // Check for unread message badge
  });

  testWidgets('GroupChatTileTablet can be dismissed',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 1,
          sentByMe: false,
          recentMessageSender: 'user1',
        ));
    const String username = "User1";
    bool isDismissed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupChatTileTablet(
            databaseService: mockDatabaseService,
            selectedGroupId: '',
            group: testGroup,
            onPressed: (Group group) {},
            username: username,
            onDismissed: (DismissDirection direction) {
              isDismissed = true;
            },
          ),
        ),
      ),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-300, 0));
    await tester.pumpAndSettle();

    expect(isDismissed, true);
  });
}
