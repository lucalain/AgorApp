import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/widgets/chats/private_chat_tile_tablet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets(
      'PrivateChatTileTablet displays username and last message when it is not selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final privateChat = PrivateChat(
        id: "1",
        members: ['uid1', 'uid2'],
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 1,
          sentByMe: false,
          recentMessageSender: 'user',
        ));

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTileTablet(
            databaseService: mockDatabaseService,
            selectedChatId: '',
            privateChat: privateChat,
            onPressed: (chat) {},
            other: user,
            onDismissed: (direction) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('user'), findsOneWidget);
    expect(find.text('user: Hello!'), findsOneWidget);
    expect(find.text("1"), findsOneWidget); // Check for unread message badge
  });
  testWidgets(
      'PrivateChatTileTablet displays username and last message when it is selected',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final privateChat = PrivateChat(
        id: "1",
        members: ['uid1', 'uid2'],
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 1,
          sentByMe: false,
          recentMessageSender: 'user',
        ));

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(0));
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTileTablet(
            databaseService: mockDatabaseService,
            selectedChatId: '1',
            privateChat: privateChat,
            onPressed: (chat) {},
            other: user,
            onDismissed: (direction) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('user'), findsOneWidget);
    expect(find.text('user: Hello!'), findsOneWidget);
  });

  testWidgets(
      'PrivateChatTileTablet displays correct icon for event message type',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
    final privateChatEvent = PrivateChat(
      id: "1",
      members: ['uid1', 'uid2'],
      lastMessage: LastMessage(
        sentByMe: false,
        recentMessage: 'Event',
        recentMessageType: Type.event,
        recentMessageTimestamp: Timestamp.now(),
        unreadMessages: 0,
        recentMessageSender: 'user',
      ),
    );

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTileTablet(
            databaseService: mockDatabaseService,
            selectedChatId: '',
            privateChat: privateChatEvent,
            onPressed: (chat) {},
            other: user,
            onDismissed: (direction) {},
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
  });

  testWidgets('PrivateChatTileTablet handles dismiss action',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1194.0, 834.0);
    tester.view.devicePixelRatio = 1.0;
    final privateChat = PrivateChat(
      id: "1",
      members: ['uid1', 'uid2'],
      lastMessage: LastMessage(
        sentByMe: false,
        recentMessage: 'Hi!',
        recentMessageType: Type.text,
        recentMessageTimestamp: Timestamp.now(),
        unreadMessages: 0,
        recentMessageSender: 'user',
      ),
    );

    final user = UserData(
      username: 'user',
      imagePath: '',
      categories: ["category"],
      name: 'name',
      surname: 'surname',
      email: 'email',
    );

    bool isDismissed = false;
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTileTablet(
            databaseService: mockDatabaseService,
            selectedChatId: '',
            privateChat: privateChat,
            onPressed: (chat) {},
            other: user,
            onDismissed: (direction) {
              isDismissed = true;
            },
          ),
        ),
      ),
    );

    await tester.drag(find.byType(Dismissible), const Offset(-300, 0));

    await tester.pumpAndSettle();

    expect(isDismissed, isTrue);
  });
}
