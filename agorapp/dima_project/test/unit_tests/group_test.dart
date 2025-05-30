import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/models/message.dart';

void main() {
  group('Group class test', () {
    test('Test Group constructor', () {
      Group group = Group(
        name: 'groupName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        lastMessage: null,
        categories: ['category1', 'category2'],
        members: ['admin'],
        requests: [],
      );
      expect(group.name, 'groupName');
      expect(group.description, 'description');
      expect(group.admin, 'admin');
      expect(group.imagePath, 'imagePath');
      expect(group.isPublic, true);
      expect(group.id, '123');
      expect(group.members, ['admin']);
      expect(group.requests, []);
      expect(group.categories, ['category1', 'category2']);
      expect(group.lastMessage, null);
    });
    test("Test toMap", () {
      Group group = Group(
        name: 'groupName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        lastMessage: null,
        categories: ['category1', 'category2'],
        members: ['admin'],
        requests: [],
      );
      Map<String, dynamic> groupMap = Group.toMap(group);
      expect(groupMap['groupId'], '123');
      expect(groupMap['groupName'], 'groupName');
      expect(groupMap['description'], 'description');
      expect(groupMap['groupImage'], 'imagePath');
      expect(groupMap['categories'], [
        {'value': 'category1'},
        {'value': 'category2'}
      ]);

      expect(groupMap['isPublic'], true);
    });
    test("Test fromSnapshot", () async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('groups').doc('123').set({
        'groupId': '123',
        'groupName': 'groupName',
        'description': 'description',
        'groupImage': 'imagePath',
        'admin': 'admin',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'recentMessage': '',
        'members': ['admin'],
        'requests': [],
      });
      await firestore.collection('groups').doc('456').set({
        'groupId': '456',
        'groupName': 'groupName1',
        'description': 'description1',
        'groupImage': 'imagePath1',
        'admin': 'admin1',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'members': ['admin1'],
        'requests': [],
        'recentMessage': 'text',
        'recentMessageType': 'Type.text',
        'recentMessageSender': 'admin1',
        'recentMessageTime': Timestamp.fromDate(DateTime(2021, 1, 1)),
      });
      await firestore.collection('groups').doc('789').set({
        'groupId': '789',
        'groupName': 'groupName2',
        'description': 'description2',
        'groupImage': 'imagePath2',
        'admin': 'admin2',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'members': ['admin2'],
        'requests': [],
        'recentMessage': 'Event',
        'recentMessageType': 'Type.event',
        'recentMessageSender': 'admin2',
        'recentMessageTime': Timestamp.fromDate(DateTime(2021, 1, 1)),
      });
      await firestore.collection('groups').doc('aaa').set({
        'groupId': 'aaa',
        'groupName': 'groupName3',
        'description': 'description3',
        'groupImage': 'imagePath3',
        'admin': 'admin3',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'members': ['admin3'],
        'requests': [],
        'recentMessage': 'News',
        'recentMessageType': 'Type.news',
        'recentMessageSender': 'admin3',
        'recentMessageTime': Timestamp.fromDate(DateTime(2021, 1, 1)),
      });
      await firestore.collection('groups').doc('bbb').set({
        'groupId': 'bbb',
        'groupName': 'groupName4',
        'description': 'description4',
        'groupImage': 'imagePath4',
        'admin': 'admin4',
        'categories': [
          {'value': 'category1'},
          {'value': 'category2'}
        ],
        'isPublic': true,
        'members': ['admin4'],
        'requests': [],
        'recentMessage': 'Image',
        'recentMessageType': 'Type.image',
        'recentMessageSender': 'admin4',
        'recentMessageTime': Timestamp.fromDate(DateTime(2021, 1, 1)),
      });
      DocumentSnapshot documentSnapshot =
          await firestore.collection('groups').doc('123').get();
      DocumentSnapshot documentSnapshot1 =
          await firestore.collection('groups').doc('456').get();
      DocumentSnapshot documentSnapshot2 =
          await firestore.collection('groups').doc('789').get();
      DocumentSnapshot documentSnapshot3 =
          await firestore.collection('groups').doc('aaa').get();
      DocumentSnapshot documentSnapshot4 =
          await firestore.collection('groups').doc('bbb').get();

      Group group = Group.fromSnapshot(documentSnapshot);
      expect(group.id, '123');
      expect(group.name, 'groupName');

      expect(group.lastMessage, null);
      expect(group.admin, 'admin');
      expect(group.description, 'description');
      expect(group.imagePath, 'imagePath');
      expect(group.categories, ['category1', 'category2']);
      expect(group.isPublic, true);
      expect(group.members, ['admin']);
      expect(group.requests, []);
      Group group1 = Group.fromSnapshot(documentSnapshot1);
      expect(group1.id, '456');
      expect(group1.name, 'groupName1');
      expect(group1.lastMessage!.recentMessage, 'text');
      expect(group1.lastMessage!.recentMessageType, Type.text);
      expect(group1.lastMessage!.recentMessageSender, 'admin1');
      expect(group1.lastMessage!.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(group1.admin, 'admin1');
      expect(group1.description, 'description1');
      expect(group1.imagePath, 'imagePath1');
      expect(group1.categories, ['category1', 'category2']);
      expect(group1.isPublic, true);
      expect(group1.members, ['admin1']);
      expect(group1.requests, []);
      Group group2 = Group.fromSnapshot(documentSnapshot2);
      expect(group2.id, '789');
      expect(group2.name, 'groupName2');
      expect(group2.lastMessage!.recentMessage, 'Event');
      expect(group2.lastMessage!.recentMessageType, Type.event);
      expect(group2.lastMessage!.recentMessageSender, 'admin2');
      expect(group2.lastMessage!.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(group2.admin, 'admin2');
      expect(group2.description, 'description2');
      expect(group2.imagePath, 'imagePath2');
      expect(group2.categories, ['category1', 'category2']);
      expect(group2.isPublic, true);
      expect(group2.members, ['admin2']);
      expect(group2.requests, []);
      Group group3 = Group.fromSnapshot(documentSnapshot3);
      expect(group3.id, 'aaa');
      expect(group3.name, 'groupName3');
      expect(group3.lastMessage!.recentMessage, 'News');
      expect(group3.lastMessage!.recentMessageType, Type.news);
      expect(group3.lastMessage!.recentMessageSender, 'admin3');
      expect(group3.lastMessage!.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(group3.admin, 'admin3');
      expect(group3.description, 'description3');
      expect(group3.imagePath, 'imagePath3');
      expect(group3.categories, ['category1', 'category2']);
      expect(group3.isPublic, true);
      expect(group3.members, ['admin3']);
      expect(group3.requests, []);
      Group group4 = Group.fromSnapshot(documentSnapshot4);
      expect(group4.id, 'bbb');
      expect(group4.name, 'groupName4');
      expect(group4.lastMessage!.recentMessage, 'Image');
      expect(group4.lastMessage!.recentMessageType, Type.image);
      expect(group4.lastMessage!.recentMessageSender, 'admin4');
      expect(group4.lastMessage!.recentMessageTimestamp,
          Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(group4.admin, 'admin4');
      expect(group4.description, 'description4');
      expect(group4.imagePath, 'imagePath4');
      expect(group4.categories, ['category1', 'category2']);
      expect(group4.isPublic, true);
      expect(group4.members, ['admin4']);
      expect(group4.requests, []);
    });
  });
}
