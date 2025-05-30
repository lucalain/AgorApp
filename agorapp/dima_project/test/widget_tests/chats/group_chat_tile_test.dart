import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/chats/group_chat_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_image_picker.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';
import '../../mocks/mock_storage_service.mocks.dart';

void main() {
  testWidgets('GroupChatTile displays group name', (WidgetTester tester) async {
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: null);
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: GroupChatTile(
            storageService: MockStorageService(),
            group: testGroup,
            username: "",
            databaseService: MockDatabaseService(),
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Test Group"), findsOneWidget);
    expect(find.text("Join the conversation!"), findsOneWidget);
  });
  testWidgets(
      "GroupChatTile correctly displays the latest message content and accurately reflects the count of unread messages",
      (WidgetTester tester) async {
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
          child: GroupChatTile(
            storageService: MockStorageService(),
            group: testGroup,
            username: username,
            databaseService: mockDatabaseService,
            notificationService: MockNotificationService(),
            imagePicker: MockImagePicker(),
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
  testWidgets("GroupChatTile displays correctly the GroupChatPage when clicked",
      (WidgetTester tester) async {
    final MockDatabaseService mockDatabaseService = MockDatabaseService();

    when(mockDatabaseService.getChats(any)).thenAnswer((_) => Stream.value([]));
    Group testGroup = Group(
        id: "1",
        isPublic: true,
        name: "Test Group",
        imagePath: "",
        lastMessage: null);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupProvider.overrideWith(
            (ref, id) => Future.value(testGroup),
          ),
        ],
        child: CupertinoApp(
          home: CupertinoPageScaffold(
            child: GroupChatTile(
              storageService: MockStorageService(),
              group: testGroup,
              databaseService: mockDatabaseService,
              notificationService: MockNotificationService(),
              imagePicker: MockImagePicker(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();
    expect(find.text("Test Group"), findsOneWidget);
  });
}
