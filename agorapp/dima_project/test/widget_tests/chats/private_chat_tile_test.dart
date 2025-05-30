import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/widgets/chats/private_chat_tile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_image_picker.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';
import '../../mocks/mock_storage_service.mocks.dart';

void main() {
  testWidgets('PrivateChatTileTablet displays username and last message',
      (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(1));
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

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTile(
            storageService: MockStorageService(),
            privateChat: privateChat,
            other: user,
            databaseService: mockDatabaseService,
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
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
      'PrivateChatTileTablet displays correct icon for event message type',
      (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(0));
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
          child: PrivateChatTile(
            storageService: MockStorageService(),
            privateChat: privateChatEvent,
            other: user,
            databaseService: mockDatabaseService,
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
  });

  testWidgets('PrivateChatTile can be dismissed', (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(0));
    when(mockDatabaseService.deletePrivateChat(any))
        .thenAnswer((_) => Future.value());
    final privateChat = PrivateChat(
        id: "1",
        members: ['uid1', 'uid2'],
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 0,
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

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: PrivateChatTile(
            storageService: MockStorageService(),
            privateChat: privateChat,
            other: user,
            databaseService: mockDatabaseService,
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('user'), findsOneWidget);
    expect(find.text('user: Hello!'), findsOneWidget);

    await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    verify(mockDatabaseService.deletePrivateChat(privateChat)).called(1);
  });
  testWidgets(
      "Navigating to private chat screen when PrivateChatTile is tapped",
      (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();
    when(mockDatabaseService.getUnreadMessages(any, any))
        .thenAnswer((_) => Stream.value(0));
    when(mockDatabaseService.getPrivateChatIdFromMembers(any))
        .thenAnswer((_) => Stream.value("1"));

    final privateChat = PrivateChat(
        id: "1",
        members: ['uid1', 'uid2'],
        lastMessage: LastMessage(
          recentMessage: "Hello!",
          recentMessageType: Type.text,
          recentMessageTimestamp: Timestamp.fromDate(
            DateTime(2024, 8, 5, 1, 1),
          ),
          unreadMessages: 0,
          sentByMe: false,
          recentMessageSender: 'user',
        ));
    when(mockDatabaseService.getPrivateChats(any))
        .thenAnswer((_) => Stream.value([]));
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
          child: PrivateChatTile(
            storageService: MockStorageService(),
            privateChat: privateChat,
            other: user,
            databaseService: mockDatabaseService,
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(PrivateChatTile));
    await tester.pumpAndSettle();

    expect(find.byType(PrivateChatPage), findsOneWidget);
  });
}
