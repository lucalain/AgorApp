import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';

void main() {
  group('Private Chat class test', () {
    test('Test Private Chat constructor', () {
      PrivateChat privateChat = PrivateChat(
        members: ['member1', 'member2'],
        lastMessage: null,
        id: '123',
      );
      expect(privateChat.members, ['member1', 'member2']);
      expect(privateChat.lastMessage, null);
      expect(privateChat.id, '123');
    });
    test("Test fromSnapshot", () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('private_chats').doc('123').set({
        'members': ['member1', 'member2'],
        'recentMessage': 'message',
        'recentMessageType': 'Type.text',
        'recentMessageSender': 'sender',
        'recentMessageTime': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      });
      DocumentSnapshot documentSnapshot =
          await firestore.collection('private_chats').doc('123').get();
      PrivateChat privateChat = PrivateChat.fromSnapshot(documentSnapshot);
      expect(privateChat.members, ['member1', 'member2']);
      expect(privateChat.lastMessage!.recentMessageType, Type.text);
      expect(privateChat.lastMessage!.recentMessage, 'message');
      expect(privateChat.lastMessage!.recentMessageSender, 'sender');
      expect(privateChat.lastMessage!.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(privateChat.id, '123');
    });
    test("Test fromMap", () {
      PrivateChat privateChat = PrivateChat.fromMap({
        'private_chat_members': "[member1, member2]",
        'private_chat_id': '123',
      });
      expect(privateChat.members, ['member1', 'member2']);
      expect(privateChat.id, '123');
    });
  });
}
