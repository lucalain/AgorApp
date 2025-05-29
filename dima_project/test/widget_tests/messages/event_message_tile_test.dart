import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/messages/event_deleted_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';

void main() {
  testWidgets(
      'EventMessageTile displays event data correctly and navigates on tap',
      (WidgetTester tester) async {
    AuthService.setUid('test_uid');
    final message = Message(
      content: 'event_id',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
      senderImage: '',
      isGroupMessage: false,
      sender: 'test_uid',
      readBy: [
        ReadBy(
          username: 'test_uid',
          readAt: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
        ),
      ],
      type: Type.event,
    );

    final eventMock = Event(
        id: 'event_id',
        name: 'Sample Event',
        description: 'Event Description',
        imagePath: '',
        admin: 'test_uid',
        isPublic: true,
        details: [
          EventDetails(
            members: ['test_uid'],
            startDate: DateTime(2021, 1, 1, 1, 1),
            startTime: DateTime(2021, 1, 1, 1, 1),
            endDate: DateTime(2021, 1, 1, 1, 1),
            endTime: DateTime(2021, 1, 1, 1, 1),
            location: 'Location',
          ),
        ]);

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            eventProvider.overrideWith(
              (ref, id) => Future(() => eventMock),
            ),
            databaseServiceProvider.overrideWithValue(MockDatabaseService()),
            notificationServiceProvider
                .overrideWithValue(MockNotificationService()),
          ],
          child: CupertinoApp(
            home: EventMessageTile(
              databaseService: MockDatabaseService(),
              message: message,
              senderUsername: 'Sender Username',
            ),
          ),
        ),
      );
    });

    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Sample Event'), findsOneWidget);
    expect(find.text('Event Description'), findsOneWidget);

    await tester.tap(find.text('Sample Event'));
    await tester.pumpAndSettle();

    expect(find.text('Sample Event'), findsOneWidget);
    expect(find.text('Event Description'), findsOneWidget);
  });

  testWidgets('EventMessageTile handles error state',
      (WidgetTester tester) async {
    AuthService.setUid('test_uid');
    final message = Message(
      content: 'Content',
      sentByMe: false,
      time: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'test_uid',
      readBy: [
        ReadBy(
          username: 'test_uid',
          readAt: Timestamp.fromDate(DateTime(2021, 1, 1, 1, 1)),
        ),
      ],
      type: Type.image,
    );

    // Build the widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventProvider.overrideWith((ref, id) => Future.error('Error')),
          databaseServiceProvider.overrideWithValue(MockDatabaseService()),
        ],
        child: CupertinoApp(
          home: EventMessageTile(
            databaseService: MockDatabaseService(),
            message: message,
            senderUsername: 'Sender Username',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // Check for the EventDeletedMessageTile
    expect(find.byType(EventDeletedMessageTile), findsOneWidget);
  });
}
