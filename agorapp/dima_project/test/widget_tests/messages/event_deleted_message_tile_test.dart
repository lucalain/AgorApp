import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/messages/event_deleted_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  group('EventDeletedMessageTile Tests', () {
    testWidgets(
        'EventDeletedMessageTile renders correctly for private chats sent by me',
        (WidgetTester tester) async {
      AuthService.setUid('test_uid');
      // Create a test Message object
      final testMessage = Message(
        sentByMe: true,
        isGroupMessage: false,
        senderImage: 'test_image.png',
        time: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
        sender: 'test_uid',
        readBy: [
          ReadBy(
            username: 'test_uid',
            readAt: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
          )
        ],
        type: Type.event,
        content: '',
      );

      // Build the widget
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Column(
              children: [
                EventDeletedMessageTile(
                    message: testMessage,
                    databaseService: MockDatabaseService()),
              ],
            ),
          ),
        ),
      );

      // Check if the widget displays "Event deleted"
      expect(find.text('Event deleted'), findsOneWidget);

      // Check if the icon is displayed
      expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);

      // Check if the message is aligned to the right
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, Alignment.centerRight);
    });

    testWidgets(
        'EventDeletedMessageTile renders correctly for group messages sent by me',
        (WidgetTester tester) async {
      AuthService.setUid('test_uid');
      // Create a test Message object
      final testMessage = Message(
        sentByMe: true,
        isGroupMessage: true,
        senderImage: '',
        time: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
        sender: 'test_uid',
        readBy: [
          ReadBy(
            username: 'test_uid',
            readAt: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
          )
        ],
        type: Type.event,
        content: '',
      );

      // Build the widget
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Column(
              children: [
                EventDeletedMessageTile(
                    message: testMessage,
                    databaseService: MockDatabaseService()),
              ],
            ),
          ),
        ),
      );

      // Check if the widget displays "Event deleted"
      expect(find.text('Event deleted'), findsOneWidget);

      // Check if the icon is displayed
      expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);

      // Check if the message is aligned to the left
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.alignment, Alignment.centerRight);
    });
  });
}
