import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets('TextMessageTile displays correctly',
      (WidgetTester tester) async {
    // Create a mock Message object
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
      type: Type.text,
    );

    // Build the widget
    await tester.pumpWidget(
      CupertinoApp(
        home: TextMessageTile(
          focusNode: FocusNode(),
          message: message,
          senderUsername: 'Sender Username',
          showCustomSnackbar: () {},
          databaseService: MockDatabaseService(),
        ),
      ),
    );
    expect(find.text('Content'), findsOneWidget);
    expect(find.text('Sender Username'), findsOneWidget);
  });
}
