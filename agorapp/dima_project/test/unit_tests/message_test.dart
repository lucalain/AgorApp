import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/message.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Message class test', () {
    test('Test ReadBy constructor', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );
      expect(readBy.username, 'sender');
      expect(readBy.readAt, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
    });
    test('Test ReadBy fromMap', () {
      ReadBy readBy = ReadBy.fromMap({
        'username': 'sender',
        'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      });
      expect(readBy.username, 'sender');
      expect(readBy.readAt, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
    });
    test('Test Message constructor', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      Message message = Message(
        id: '123',
        content: 'message',
        sender: 'sender',
        sentByMe: false,
        isGroupMessage: false,
        time: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        chatID: '321',
        readBy: [readBy],
        type: Type.text,
        senderImage: 'image',
      );
      expect(message.id, '123');
      expect(message.content, 'message');
      expect(message.sender, 'sender');
      expect(message.sentByMe, false);
      expect(message.isGroupMessage, false);
      expect(message.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message.readBy, [readBy]);
      expect(message.chatID, '321');
      expect(message.type, Type.text);
      expect(message.senderImage, 'image');
    });
    test('Test Message toMap', () {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      Message message = Message(
        id: '123',
        content: 'message',
        sender: 'sender',
        sentByMe: false,
        isGroupMessage: false,
        time: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        chatID: '321',
        readBy: [readBy],
        type: Type.text,
        senderImage: 'image',
      );
      Map<String, dynamic> messageMap = message.toMap();
      expect(messageMap['content'], 'message');
      expect(messageMap['sender'], 'sender');
      expect(messageMap['isGroupMessage'], false);
      expect(messageMap['time'],
          Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(messageMap['readBy'], [readBy.toMap()]);
      expect(messageMap['type'], Type.text.toString());
      expect(messageMap['senderImage'], 'image');
    });
    test('Test Message fromSnapshot', () async {
      ReadBy readBy = ReadBy(
        username: 'sender',
        readAt: Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
      );

      final firestore = FakeFirebaseFirestore();
      await firestore.collection('messages').doc('123').set({
        'content': 'message',
        'sender': 'sender',
        'isGroupMessage': false,
        'time': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        'readBy': [
          {
            'username': 'sender',
            'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
          }
        ],
        'type': 'Type.text',
        'senderImage': 'image',
      });
      await firestore.collection('messages').doc('456').set({
        'content': 'message1',
        'sender': 'sender',
        'isGroupMessage': false,
        'time': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        'readBy': [
          {
            'username': 'sender',
            'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
          }
        ],
        'type': 'Type.image',
        'senderImage': 'image',
      });
      await firestore.collection('messages').doc('789').set({
        'content': 'message2',
        'sender': 'sender',
        'isGroupMessage': false,
        'time': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        'readBy': [
          {
            'username': 'sender',
            'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
          }
        ],
        'type': 'Type.news',
        'senderImage': 'image',
      });
      await firestore.collection('messages').doc('aaa').set({
        'content': 'message3',
        'sender': 'sender',
        'isGroupMessage': false,
        'time': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
        'readBy': [
          {
            'username': 'sender',
            'readAt': Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)),
          }
        ],
        'type': 'Type.event',
        'senderImage': 'image',
      });
      DocumentSnapshot documentSnapshot =
          await firestore.collection('messages').doc('123').get();
      DocumentSnapshot documentSnapshot1 =
          await firestore.collection('messages').doc('456').get();
      DocumentSnapshot documentSnapshot2 =
          await firestore.collection('messages').doc('789').get();
      DocumentSnapshot documentSnapshot3 =
          await firestore.collection('messages').doc('aaa').get();

      Message message =
          Message.fromSnapshot(documentSnapshot, '321', 'currentUsername');
      expect(message.id, '123');
      expect(message.content, 'message');
      expect(message.sender, 'sender');
      expect(message.sentByMe, false);
      expect(message.isGroupMessage, false);
      expect(message.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message.readBy, [readBy]);
      expect(message.chatID, '321');
      expect(message.type, Type.text);
      expect(message.senderImage, 'image');

      Message message1 =
          Message.fromSnapshot(documentSnapshot1, '456', 'currentUsername');
      expect(message1.id, '456');
      expect(message1.content, 'message1');
      expect(message1.sender, 'sender');
      expect(message1.sentByMe, false);
      expect(message1.isGroupMessage, false);
      expect(message1.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message1.readBy, [readBy]);
      expect(message1.chatID, '456');
      expect(message1.type, Type.image);
      expect(message1.senderImage, 'image');

      Message message2 =
          Message.fromSnapshot(documentSnapshot2, '789', 'currentUsername');
      expect(message2.id, '789');
      expect(message2.content, 'message2');
      expect(message2.sender, 'sender');
      expect(message2.sentByMe, false);
      expect(message2.isGroupMessage, false);
      expect(message2.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message2.readBy, [readBy]);
      expect(message2.chatID, '789');
      expect(message2.type, Type.news);
      expect(message2.senderImage, 'image');
      Message message3 =
          Message.fromSnapshot(documentSnapshot3, 'aaa', 'currentUsername');
      expect(message3.id, 'aaa');
      expect(message3.content, 'message3');
      expect(message3.sender, 'sender');
      expect(message3.sentByMe, false);
      expect(message3.isGroupMessage, false);
      expect(message3.time, Timestamp.fromDate(DateTime(2021, 12, 12, 12, 12)));
      expect(message3.readBy, [readBy]);
      expect(message3.chatID, 'aaa');
      expect(message3.type, Type.event);
      expect(message3.senderImage, 'image');
    });
  });
}
