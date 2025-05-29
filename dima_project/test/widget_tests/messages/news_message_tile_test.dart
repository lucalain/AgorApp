import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets('NewsMessageTile displays correctly and navigates on tap',
      (WidgetTester tester) async {
    AuthService.setUid('test_uid');
    final message = Message(
      content: 'Title\nDescription\nhttps://example.com\nhttps://imageurl.com',
      sentByMe: true,
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
      type: Type.news,
    );

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        CupertinoApp(
          home: NewsMessageTile(
            message: message,
            databaseService: MockDatabaseService(),
          ),
        ),
      );
    });

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();

    expect(find.byType(ArticleView), findsOneWidget);
  });
}
