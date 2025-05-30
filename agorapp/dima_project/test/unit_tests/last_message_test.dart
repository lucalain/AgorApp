import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Last Message class test', () {
    test('Test Last Message constructor', () {
      LastMessage lastMessage = LastMessage(
        recentMessageType: Type.text,
        recentMessage: 'message',
        recentMessageSender: 'sender',
        recentMessageTimestamp:
            Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        unreadMessages: 1,
        sentByMe: false,
      );
      expect(lastMessage.recentMessageType, Type.text);
      expect(lastMessage.recentMessage, 'message');
      expect(lastMessage.recentMessageSender, 'sender');
      expect(lastMessage.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(lastMessage.unreadMessages, 1);
      expect(lastMessage.sentByMe, false);
    });
  });
}
