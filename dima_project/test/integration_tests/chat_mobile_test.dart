import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/chat_page.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/groups/invite_user_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/user_invitation_tile.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:dima_project/models/message.dart';
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:mockito/mockito.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shimmer/shimmer.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_image_picker.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';
import '../mocks/mock_storage_service.mocks.dart';

class MockXFile extends mocktail.Mock implements XFile {
  @override
  readAsBytes() async {
    return Future.value(Uint8List(0));
  }
}

void main() {
  final MockXFile mockXFile = MockXFile();
  final UserData fakeUserData1 = UserData(
      uid: 'uid1',
      name: 'name1',
      email: 'mail1',
      imagePath: '',
      surname: 'surname1',
      username: 'username1',
      categories: ['Environment'],
      isPublic: true);
  final UserData fakeUserData2 = UserData(
      uid: 'uid2',
      name: 'name2',
      email: 'mail2',
      imagePath: '',
      surname: 'surname2',
      username: 'username2',
      categories: ['Environment'],
      isPublic: true);
  final UserData fakeUserData3 = UserData(
      uid: 'uid3',
      name: 'name3',
      email: 'mail3',
      imagePath: '',
      surname: 'surname3',
      username: 'username3',
      categories: ['Environment'],
      isPublic: true);
  final PrivateChat fakePrivateChat1 = PrivateChat(
    id: '321',
    members: ['user1', 'user2'],
    lastMessage: LastMessage(
      recentMessage: 'Hello',
      recentMessageSender: 'user1',
      recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
      recentMessageType: Type.text,
      sentByMe: true,
      unreadMessages: 0,
    ),
  );
  final PrivateChat fakePrivateChat2 = PrivateChat(
    id: '432',
    members: ['user1', 'user3'],
    lastMessage: LastMessage(
      recentMessage: 'Hello',
      recentMessageSender: 'user1',
      recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
      recentMessageType: Type.text,
      sentByMe: true,
      unreadMessages: 0,
    ),
  );
  final Group fakeGroup1 = Group(
    id: '123',
    name: 'Group1',
    admin: 'user1',
    isPublic: false,
    members: [
      'user1',
      'user2',
    ],
    imagePath: '',
    description: 'Description',
    categories: ['Environment'],
    lastMessage: LastMessage(
        recentMessage: 'Hello',
        recentMessageSender: 'user1',
        recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
        recentMessageType: Type.text,
        unreadMessages: 0,
        sentByMe: true),
  );
  final Group fakeGroup2 = Group(
    id: '123',
    name: 'Group2',
    imagePath: '',
    isPublic: false,
    members: ['user1', 'user2'],
    lastMessage: null,
  );

  List<ReadBy> readBy = [
    ReadBy(
      username: 'user1',
      readAt: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
    ),
    ReadBy(
      username: 'user2',
      readAt: Timestamp.fromDate(DateTime(2024, 2, 3, 1, 1)),
    ),
  ];
  List<Message> messages = [
    Message(
      content: 'Hello',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.text,
    ),
    Message(
      content: 'Title\nDescription\nhttps://example.com\nhttps://imageurl.com',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.news,
    ),
    Message(
      content: 'https://imageurl.com',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.image,
      id: 'image_id',
    ),
    Message(
      content: 'event_id',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.event,
    )
  ];
  List<Message> medias = [
    Message(
      content: 'https://imageurl.com',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 2, 2, 2, 2)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user3',
      readBy: readBy,
      type: Type.image,
      id: 'image_id',
    ),
    Message(
      content: 'https://imageurl1.com',
      sentByMe: true,
      time: Timestamp.fromDate(DateTime(2024, 3, 3, 3, 3)),
      senderImage: '',
      isGroupMessage: true,
      sender: 'user1',
      readBy: readBy,
      type: Type.image,
      id: 'image_id1',
    ),
  ];

  late final MockDatabaseService mockDatabaseService;
  late final MockNotificationService mockNotificationService;
  late final MockImagePicker mockImagePicker;
  late final MockStorageService mockStorageService;
  setUpAll(() {
    mockDatabaseService = MockDatabaseService();
    mockNotificationService = MockNotificationService();
    mockImagePicker = MockImagePicker();
    mockStorageService = MockStorageService();
  });

  group('ChatPage Tests for mobile', () {
    testWidgets(
        'Displays no chat messages on ChatPage for mobile when no chats and groups exist',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        CupertinoApp(
          home: ChatPage(
            storageService: mockStorageService,
            databaseService: mockDatabaseService,
            notificationService: mockNotificationService,
            imagePicker: mockImagePicker,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create a group to start chatting'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No chats yet'), findsOneWidget);
      expect(find.text('Create a chat to start chatting'), findsOneWidget);
    });
    testWidgets(
        'Displays no chat messages on ChatPage for mobile in dark mode when no chats and groups exist',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(platformBrightness: Brightness.dark),
          child: CupertinoApp(
            home: ChatPage(
              storageService: mockStorageService,
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Create a group to start chatting'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No chats yet'), findsOneWidget);
      expect(find.text('Create a chat to start chatting'), findsOneWidget);
    });
    testWidgets(
        'Chat page displays chats and groups for mobile and navigation works',
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('user2').set({
        'uid': 'user2',
        'name': 'name2',
        'email': 'mail2',
        'imageUrl': '',
        'surname': 'surname2',
        'username': 'username2',
        'requests': [],
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'token': 'token2',
        'isSignedInWithGoogle': false,
        'groups': ['123', '456'],
      });
      await firestore.collection('users').doc('user1').set({
        'uid': 'user1',
        'name': 'name1',
        'email': 'mail1',
        'requests': [],
        'imageUrl': '',
        'surname': 'surname1',
        'username': 'username1',
        'isPublic': true,
        'token': 'token1',
        'isSignedInWithGoogle': false,
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'groups': ['123', '456'],
      });
      DocumentSnapshot documentSnapshot2 =
          await firestore.collection('users').doc('user2').get();
      DocumentSnapshot documentSnapshot1 =
          await firestore.collection('users').doc('user1').get();
      when(mockDatabaseService.getPrivateChatsStream()).thenAnswer(
          (_) => Stream.value([fakePrivateChat1, fakePrivateChat2]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([fakeGroup1, fakeGroup2]));
      when(mockDatabaseService.getUserDataFromUID('user2'))
          .thenAnswer((_) => Stream.value(documentSnapshot2));
      when(mockDatabaseService.getUserDataFromUID('user3')).thenAnswer((_) {
        return Stream.error('User not found');
      });
      when(mockDatabaseService.getUserDataFromUID('user1'))
          .thenAnswer((_) => Stream.value(documentSnapshot1));
      when(mockDatabaseService.getUnreadMessages(any, any))
          .thenAnswer((_) => Stream.value(0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
          ],
          child: CupertinoApp(
            home: ChatPage(
              storageService: mockStorageService,
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.add_circled_solid));
      await tester.pumpAndSettle();
      expect(find.text('Create'), findsOneWidget); // Create group page
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Group1'), findsOneWidget); // Chat page
      expect(find.text('Group2'), findsOneWidget);
      expect(find.text('You: Hello'), findsOneWidget);
      expect(find.text('Join the conversation!'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'AAA');
      await tester.pumpAndSettle();
      expect(find.text('No groups found'), findsOneWidget);
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      expect(find.text('No private chats found'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), '');
      await tester.pumpAndSettle();
      expect(find.text('username2'), findsOneWidget);
      expect(find.text('Deleted Account'), findsOneWidget);
      expect(find.text('You: Hello'), findsNWidgets(2));
    });
    group('Create Group Page Tests', () {
      testWidgets(
          "CreateGroup page displays correctly and successfully creates a new group for mobile",
          (WidgetTester tester) async {
        AuthService.setUid('user1');

        when(mockDatabaseService.getPrivateChatsStream())
            .thenAnswer((_) => Stream.value([]));
        when(mockDatabaseService.getGroupsStream())
            .thenAnswer((_) => Stream.value([]));
        when(mockDatabaseService.createGroup(any, any, any)).thenAnswer(
          (_) => Future.value(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.add_circled_solid));
        await tester.pumpAndSettle();
        expect(find.text('Create'), findsOneWidget);
        await tester.enterText(find.byType(CupertinoTextField).first, 'Group3');
        await tester.enterText(
            find.byType(CupertinoTextField).at(1), 'Description');
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.clear_circled_solid).last);
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('Group description is required'), findsOneWidget);
        expect(find.text('Validation Error'), findsOneWidget);
        await tester.tap(find.text('Ok'));
        await tester.pumpAndSettle();
        await tester.enterText(
            find.byType(CupertinoTextField).at(1), 'Description');
        await tester.tap(find.text('Categories')); // Categories Page
        await tester.pumpAndSettle();
        expect(find.text('Categories Selection'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CupertinoSwitch));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Invite Followers')); // Invite Page
        await tester.pumpAndSettle();
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();

        expect(find.text('No groups yet'), findsOneWidget); // Chat Page
        expect(find.text('Create a group to start chatting'), findsOneWidget);
      });
    });
    group('Test chat functionality', () {
      testWidgets(
          "Group chat page renders correctly and send message functionality works correctly",
          (WidgetTester tester) async {
        AuthService.setUid('user1');
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'name': 'name2',
          'email': 'mail2',
          'imageUrl': '',
          'surname': 'surname2',
          'username': 'username2',
          'requests': [],
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'isPublic': true,
          'token': 'token2',
          'isSignedInWithGoogle': false,
          'groups': ['123', '456'],
        });
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'name': 'name1',
          'email': 'mail1',
          'requests': [],
          'imageUrl': '',
          'surname': 'surname1',
          'username': 'username1',
          'isPublic': true,
          'token': 'token1',
          'isSignedInWithGoogle': false,
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'groups': ['123', '456'],
        });
        DocumentSnapshot documentSnapshot2 =
            await firestore.collection('users').doc('user2').get();
        DocumentSnapshot documentSnapshot1 =
            await firestore.collection('users').doc('user1').get();
        when(mockDatabaseService.getPrivateChatsStream())
            .thenAnswer((_) => Stream.value([fakePrivateChat1]));
        when(mockDatabaseService.getGroupsStream())
            .thenAnswer((_) => Stream.value([fakeGroup1]));
        when(mockNotificationService.sendGroupNotification(any, any))
            .thenAnswer((_) => Future.value());
        when(mockDatabaseService.getUserDataFromUID('user1'))
            .thenAnswer((_) => Stream.value(documentSnapshot1));
        when(mockDatabaseService.getUserDataFromUID('user2'))
            .thenAnswer((_) => Stream.value(documentSnapshot2));
        when(mockDatabaseService.getUserDataFromUID('user3')).thenAnswer((_) {
          return Stream.error('User not found');
        });
        when(mockDatabaseService.getUserData('user1')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
        when(mockDatabaseService.getUserData('user2')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
        when(mockDatabaseService.getUserData('user3')).thenAnswer((_) async {
          return Future.value(UserData.fromSnapshot(
              await firestore.collection('users').doc('user3').get()));
        });
        when(mockDatabaseService.getUnreadMessages(any, any))
            .thenAnswer((_) => Stream.value(0));
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            return;
          },
        );
        when(mockDatabaseService.sendMessage(any, any))
            .thenAnswer((_) => Future.value());

        when(mockDatabaseService.getChats(any)).thenAnswer((_) {
          return Stream.value(messages);
        });
        when(mockImagePicker.pickImage(
                source: ImageSource.camera, imageQuality: 80))
            .thenAnswer((_) async {
          return mockXFile;
        });
        when(mockImagePicker.pickMultiImage(imageQuality: 80)).thenAnswer(
          (_) async {
            return [mockXFile];
          },
        );
        when(mockStorageService.uploadImageToStorage(any, any)).thenAnswer((_) {
          return Future.value('image_url');
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              eventProvider.overrideWith(
                (ref, eventId) async => Event(
                  id: 'event_id',
                  name: 'Sample Event',
                  description: 'Event Description',
                  imagePath: '',
                  admin: 'user1',
                  isPublic: true,
                  details: [
                    EventDetails(
                      members: ['user1', 'user2'],
                    ),
                  ],
                ),
              ),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              groupProvider.overrideWith(
                (ref, groupId) => fakeGroup1,
              ),
              userProvider.overrideWith(
                (ref, uid) async => mockDatabaseService.getUserData(uid),
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Group1'));
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);
        expect(find.text('You: Hello'), findsOneWidget);
        await tester.tap(find.text('Group1'));
        await tester.pumpAndSettle();
        await tester.longPress(find.text('Hello'));
        await tester.pumpAndSettle();
        expect(find.text('Copy Text'), findsOneWidget);
        expect(find.text('Delete Message'), findsOneWidget);
        expect(find.text('Read By'), findsOneWidget);
        await tester.tap(find.text('Copy Text'));
        await tester.pumpAndSettle();
        expect(find.text('Copied to clipboard'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(CupertinoTextField), 'Hello');
        await tester.tap(find.byIcon(LineAwesomeIcons.paper_plane));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.photo_fill));
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.camera_fill).last);
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);
      });
      testWidgets(
          "Private chat page renders correctly and send message functionality works correctly",
          (WidgetTester tester) async {
        AuthService.setUid('user1');
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'name': 'name2',
          'email': 'mail2',
          'imageUrl': '',
          'surname': 'surname2',
          'username': 'username2',
          'requests': [],
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'isPublic': true,
          'token': 'token2',
          'isSignedInWithGoogle': false,
          'groups': ['123', '456'],
        });
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'name': 'name1',
          'email': 'mail1',
          'requests': [],
          'imageUrl': '',
          'surname': 'surname1',
          'username': 'username1',
          'isPublic': true,
          'token': 'token1',
          'isSignedInWithGoogle': false,
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'groups': ['123', '456'],
        });
        DocumentSnapshot documentSnapshot2 =
            await firestore.collection('users').doc('user2').get();
        DocumentSnapshot documentSnapshot1 =
            await firestore.collection('users').doc('user1').get();
        when(mockDatabaseService
                .getPrivateChatIdFromMembers(['user1', 'user2']))
            .thenAnswer((_) => Stream.value('321'));
        when(mockDatabaseService.getPrivateChatsStream())
            .thenAnswer((_) => Stream.value([fakePrivateChat1]));
        when(mockDatabaseService.getGroupsStream())
            .thenAnswer((_) => Stream.value([]));
        when(mockNotificationService.sendPrivateChatNotification(any, any))
            .thenAnswer((_) => Future.value());
        when(mockDatabaseService.getUserDataFromUID('user1'))
            .thenAnswer((_) => Stream.value(documentSnapshot1));
        when(mockDatabaseService.getUserDataFromUID('user2'))
            .thenAnswer((_) => Stream.value(documentSnapshot2));
        when(mockDatabaseService.getUnreadMessages(any, any)).thenAnswer((_) {
          return Stream.value(0);
        });
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            return;
          },
        );
        when(mockDatabaseService.sendMessage(any, any))
            .thenAnswer((_) => Future.value());

        when(mockDatabaseService.getPrivateChats(any)).thenAnswer((_) {
          return Stream.value(messages);
        });
        when(mockImagePicker.pickImage(
                source: ImageSource.camera, imageQuality: 80))
            .thenAnswer((_) async {
          return mockXFile;
        });
        when(mockImagePicker.pickMultiImage(imageQuality: 80)).thenAnswer(
          (_) async {
            return [mockXFile];
          },
        );
        when(mockStorageService.uploadImageToStorage(any, any)).thenAnswer((_) {
          return Future.value('image_url');
        });
        when(mockDatabaseService.getUserData('user1')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
        when(mockDatabaseService.getUserData('user2')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
        when(mockDatabaseService.getUserData('user3')).thenAnswer((_) async {
          return Future.value(UserData.fromSnapshot(
              await firestore.collection('users').doc('user3').get()));
        });

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              eventProvider.overrideWith(
                (ref, eventId) async => Event(
                    id: 'event_id',
                    name: 'Sample Event',
                    description: 'Event Description',
                    imagePath: '',
                    admin: 'user1',
                    isPublic: true,
                    details: [
                      EventDetails(
                        startDate: DateTime.now(),
                        startTime: DateTime.now(),
                        endDate: DateTime.now(),
                        endTime: DateTime.now(),
                        latlng: const LatLng(0, 0),
                        location: 'Location',
                        id: 'event_id',
                        requests: [],
                        members: ['user1'],
                      ),
                    ]),
              ),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              imagesGroupProvider.overrideWith(
                (ref, groupId) => [messages[2]],
              ),
              eventsGroupProvider.overrideWith(
                (ref, groupId) => [messages[3]],
              ),
              newsGroupProvider.overrideWith(
                (ref, groupId) => [messages[1]],
              ),
              requestsGroupProvider.overrideWith(
                (ref, groupId) => [fakeUserData1, fakeUserData2, fakeUserData3],
              ),
              groupProvider.overrideWith(
                (ref, groupId) => fakeGroup1,
              ),
              userProvider.overrideWith(
                (ref, uid) async => mockDatabaseService.getUserData(uid),
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('username2'));
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsOneWidget);
        expect(find.text('You: Hello'), findsOneWidget);
        await tester.tap(find.text('username2'));
        await tester.pumpAndSettle();
        await tester.longPress(find.text('Hello'));
        await tester.pumpAndSettle();
        expect(find.text('Copy Text'), findsOneWidget);
        expect(find.text('Delete Message'), findsOneWidget);
        expect(find.text('Read By'), findsOneWidget);
        await tester.tap(find.text('Copy Text'));
        await tester.pumpAndSettle();
        expect(find.text('Copied to clipboard'), findsOneWidget);
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(CupertinoTextField), 'Hello');
        await tester.tap(find.byIcon(LineAwesomeIcons.paper_plane));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.photo_fill));
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsOneWidget);
        await tester.tap(find.byIcon(CupertinoIcons.camera_fill).last);
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsOneWidget);
      });
      testWidgets("Group chat page navigations work correctly for mobile",
          (WidgetTester tester) async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'name': 'name1',
          'email': 'mail1',
          'requests': [],
          'imageUrl': '',
          'surname': 'surname1',
          'username': 'username1',
          'isPublic': true,
          'token': 'token1',
          'isSignedInWithGoogle': false,
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'groups': ['123', '456'],
        });
        await firestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'name': 'name2',
          'email': 'mail2',
          'imageUrl': '',
          'surname': 'surname2',
          'username': 'username2',
          'requests': [],
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'isPublic': true,
          'token': 'token2',
          'isSignedInWithGoogle': false,
          'groups': ['123', '456'],
        });

        AuthService.setUid('user1');
        DocumentSnapshot documentSnapshot1 =
            await firestore.collection('users').doc('user1').get();
        DocumentSnapshot documentSnapshot2 =
            await firestore.collection('users').doc('user2').get();

        when(mockDatabaseService.getGroupsStream())
            .thenAnswer((_) => Stream.value([fakeGroup1]));
        when(mockDatabaseService.getPrivateChatsStream())
            .thenAnswer((_) => Stream.value([]));

        when(mockDatabaseService.getChats(any)).thenAnswer((_) {
          return Stream.value(messages);
        });
        when(mockDatabaseService.getUserDataFromUID('user1'))
            .thenAnswer((_) => Stream.value(documentSnapshot1));
        when(mockDatabaseService.getUserDataFromUID('user2'))
            .thenAnswer((_) => Stream.value(documentSnapshot2));
        when(mockDatabaseService.getNotification(any, any)).thenAnswer(
          (_) => Future.value(true),
        );
        when(mockDatabaseService.getGroupMessagesType(any, Type.news))
            .thenAnswer(
          (_) => Future.value([messages[1]]),
        );
        when(mockDatabaseService.getGroupMessagesType(any, Type.image))
            .thenAnswer(
          (_) => Future.value([messages[2]]),
        );
        when(mockDatabaseService.getGroupMessagesType(any, Type.event))
            .thenAnswer(
          (_) => Future.value([messages[3]]),
        );
        when(mockDatabaseService.getUserData('user1')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
        when(mockDatabaseService.getUserData('user2')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
        when(mockDatabaseService.getUserData('user3')).thenAnswer((_) async {
          return Future.value(UserData.fromSnapshot(
              await firestore.collection('users').doc('user3').get()));
        });

        when(mockNotificationService.sendGroupNotification(any, any))
            .thenAnswer((_) => Future.value());
        when(mockDatabaseService.sendMessage(any, any))
            .thenAnswer((_) => Future.value());
        when(mockImagePicker.pickImage(
                source: ImageSource.camera, imageQuality: 80))
            .thenAnswer((_) async {
          return mockXFile;
        });
        when(mockImagePicker.pickMultiImage(imageQuality: 80)).thenAnswer(
          (_) async {
            return [mockXFile];
          },
        );
        when(mockStorageService.uploadImageToStorage(any, any)).thenAnswer((_) {
          return Future.value('image_url');
        });
        when(mockDatabaseService.getGroupRequestsForGroup(any)).thenAnswer((_) {
          return Future.value([fakeUserData1, fakeUserData2, fakeUserData3]);
        });
        when(mockDatabaseService.updateNotification(any, any, any))
            .thenAnswer((_) {
          return Future.value();
        });
        when(mockDatabaseService.acceptGroupRequest(any, "uid1")).thenAnswer(
          ((_) => Future.value()),
        );
        when(mockDatabaseService.acceptGroupRequest(any, "uid2")).thenAnswer(
          ((_) => Future.error('User deleted his account')),
        );
        when(mockDatabaseService.denyGroupRequest(any, "uid3")).thenAnswer(
          ((_) => Future.value()),
        );

        when(mockDatabaseService.getGroupFromId(any))
            .thenAnswer((_) => Future.value(fakeGroup1));

        when(mockDatabaseService.getEvent('event_id')).thenAnswer(
          (_) => Future.value(
            Event(
                id: 'event_id',
                name: 'Sample Event',
                description: 'Event Description',
                imagePath: '',
                admin: 'user1',
                isPublic: true,
                details: [
                  EventDetails(
                    startDate: DateTime.now(),
                    startTime: DateTime.now(),
                    endDate: DateTime.now(),
                    endTime: DateTime.now(),
                    latlng: const LatLng(0, 0),
                    location: 'Location',
                    id: 'event_id',
                    requests: [],
                    members: ['user1'],
                  ),
                ]),
          ),
        );

        when(mockDatabaseService.getUnreadMessages(any, any)).thenAnswer((_) {
          return Stream.value(0);
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              imagesGroupProvider.overrideWith(
                (ref, groupId) => [messages[2]],
              ),
              eventsGroupProvider.overrideWith(
                (ref, groupId) => [messages[3]],
              ),
              newsGroupProvider.overrideWith(
                (ref, groupId) => [messages[1]],
              ),
              requestsGroupProvider.overrideWith(
                (ref, groupId) => [fakeUserData1, fakeUserData2, fakeUserData3],
              ),
              groupProvider.overrideWith(
                (ref, groupId) => fakeGroup1,
              ),
              eventProvider.overrideWith(
                (ref, eventId) async => Event(
                    id: 'event_id',
                    name: 'Sample Event',
                    description: 'Event Description',
                    imagePath: '',
                    admin: 'user1',
                    isPublic: true,
                    details: [
                      EventDetails(
                        startDate: DateTime.now(),
                        startTime: DateTime.now(),
                        endDate: DateTime.now(),
                        endTime: DateTime.now(),
                        latlng: const LatLng(0, 0),
                        location: 'Location',
                        id: 'event_id',
                        requests: [],
                        members: ['user1'],
                      ),
                    ]),
              ),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              userProvider.overrideWith(
                (ref, uid) async => mockDatabaseService.getUserData(uid),
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Group1'));
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);

        await tester.tap(find.byIcon(CupertinoIcons.add));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(CupertinoIcons.calendar)); //Event
        await tester.pumpAndSettle();
        expect(find.text('Create Event'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group1'), findsOneWidget);
        await tester.tap(find.text('Group1')); //Group Info
        await tester.pumpAndSettle();

        expect(find.text('Group Info'), findsOneWidget);
        expect(find.text('Group1'), findsOneWidget);
        expect(find.text('Description'), findsOneWidget);

        await tester.tap(find.text('Requests')); //Requests
        await tester.pumpAndSettle();
        expect(find.text('Group Requests'), findsOneWidget);
        expect(find.text('username1'), findsOneWidget);
        expect(find.text('username2'), findsOneWidget);
        expect(find.text('username3'), findsOneWidget);
        await tester.tap(find.text('Accept').first);
        await tester.pumpAndSettle();
        expect(find.text('username1'), findsNothing);
        await tester.tap(find.text('Accept').first);
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsNothing);
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text('User deleted his account'), findsOneWidget);
        await tester.tap(find.text('Ok'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Deny'));
        await tester.pumpAndSettle();
        expect(find.text('username3'), findsNothing);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group Info'), findsOneWidget);

        await tester.tap(find.text('Images')); //Images
        await tester.pumpAndSettle();
        expect(find.text('Images'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group Info'), findsOneWidget);
        await tester.tap(find.text('Events')); //Events
        await tester.pumpAndSettle();

        expect(find.text('Events'), findsOneWidget);
        await tester.tap(find.text('Sample Event'));
        await tester.pumpAndSettle();
        expect(find.text('Sample Event'), findsOneWidget);
        expect(find.text('Event Description'), findsOneWidget);

        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Events'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group Info'), findsOneWidget);
        await tester.tap(find.text('News')); //News
        await tester.pumpAndSettle();
        expect(find.text('News'), findsOneWidget);
        expect(find.text('Title'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group Info'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
        await tester.tap(find.byType(CupertinoSwitch));
        await tester.pumpAndSettle();
        expect(find.text('Notifications'), findsOneWidget);
        await tester.tap(find.text('Add Members')); //Add Members
        await tester.pumpAndSettle();
        expect(find.text('Add Members'), findsOneWidget);
        expect(find.text('No followers'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Group Info'), findsOneWidget);
      });
      testWidgets("Private chat page navigations work correctly for mobile",
          (WidgetTester tester) async {
        final firestore = FakeFirebaseFirestore();
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'name': 'name1',
          'email': 'mail1',
          'requests': [],
          'imageUrl': '',
          'surname': 'surname1',
          'username': 'username1',
          'isPublic': true,
          'token': 'token1',
          'isSignedInWithGoogle': false,
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'groups': ['123', '456'],
        });
        await firestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'name': 'name2',
          'email': 'mail2',
          'imageUrl': '',
          'surname': 'surname2',
          'username': 'username2',
          'requests': [],
          'selectedCategories': [
            {'value': 'category1'},
            {'value': 'category2'},
          ],
          'isPublic': true,
          'token': 'token2',
          'isSignedInWithGoogle': false,
          'groups': ['123', '456'],
        });

        AuthService.setUid('user1');
        DocumentSnapshot documentSnapshot1 =
            await firestore.collection('users').doc('user1').get();
        DocumentSnapshot documentSnapshot2 =
            await firestore.collection('users').doc('user2').get();

        when(mockDatabaseService.getGroupsStream())
            .thenAnswer((_) => Stream.value([]));
        when(mockDatabaseService.getPrivateChatsStream())
            .thenAnswer((_) => Stream.value([fakePrivateChat1]));

        when(mockDatabaseService.getPrivateChats(any)).thenAnswer((_) {
          return Stream.value(messages);
        });
        when(mockDatabaseService
                .getPrivateChatIdFromMembers(['user1', 'user2']))
            .thenAnswer((_) => Stream.value('321'));

        when(mockDatabaseService.getUserDataFromUID('user1'))
            .thenAnswer((_) => Stream.value(documentSnapshot1));
        when(mockDatabaseService.getUserDataFromUID('user2'))
            .thenAnswer((_) => Stream.value(documentSnapshot2));
        when(mockDatabaseService.getNotification(any, any)).thenAnswer(
          (_) => Future.value(true),
        );
        when(mockDatabaseService.getPrivateMessagesType(any, Type.news))
            .thenAnswer(
          (_) => Future.value([messages[1]]),
        );
        when(mockDatabaseService.getPrivateMessagesType(any, Type.image))
            .thenAnswer(
          (_) => Future.value([messages[2]]),
        );
        when(mockDatabaseService.getPrivateMessagesType(any, Type.event))
            .thenAnswer(
          (_) => Future.value([messages[3]]),
        );
        when(mockDatabaseService.getUserData('user1')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
        when(mockDatabaseService.getUserData('user2')).thenAnswer(
            (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
        when(mockDatabaseService.getUserData('user3')).thenAnswer((_) async {
          return Future.value(UserData.fromSnapshot(
              await firestore.collection('users').doc('user3').get()));
        });

        when(mockDatabaseService.updateNotification(any, any, any))
            .thenAnswer((_) {
          return Future.value();
        });
        when(mockDatabaseService.getUnreadMessages(any, any))
            .thenAnswer((_) => Stream.value(0));
        when(mockDatabaseService.getEvent('event_id')).thenAnswer(
          (_) => Future.value(
            Event(
                id: 'event_id',
                name: 'Sample Event',
                description: 'Event Description',
                imagePath: '',
                admin: 'user1',
                isPublic: true,
                details: [
                  EventDetails(
                    startDate: DateTime.now(),
                    startTime: DateTime.now(),
                    endDate: DateTime.now(),
                    endTime: DateTime.now(),
                    latlng: const LatLng(0, 0),
                    location: 'Location',
                    id: 'event_id',
                    requests: [],
                    members: ['user1'],
                  ),
                ]),
          ),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              imagesPrivateChatProvider.overrideWith(
                (ref, groupId) => [messages[2]],
              ),
              eventsPrivateChatProvider.overrideWith(
                (ref, groupId) => [messages[3]],
              ),
              newsPrivateChatProvider.overrideWith(
                (ref, groupId) => [messages[1]],
              ),
              eventProvider.overrideWith(
                (ref, eventId) async => Event(
                    id: 'event_id',
                    name: 'Sample Event',
                    description: 'Event Description',
                    imagePath: '',
                    admin: 'user1',
                    isPublic: true,
                    details: [
                      EventDetails(
                        startDate: DateTime.now(),
                        startTime: DateTime.now(),
                        endDate: DateTime.now(),
                        endTime: DateTime.now(),
                        latlng: const LatLng(0, 0),
                        location: 'Location',
                        id: 'event_id',
                        requests: [],
                        members: ['user1'],
                      ),
                    ]),
              ),
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              userProvider.overrideWith(
                (ref, uid) async => mockDatabaseService.getUserData(uid),
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Private'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('username2'));
        await tester.pumpAndSettle();
        expect(find.text('username2'), findsOneWidget);

        await tester.tap(find.text('username2')); //Private Chat Info
        await tester.pumpAndSettle();

        expect(find.text('Private Chat Info'), findsOneWidget);
        expect(find.text('username2'), findsOneWidget);

        await tester.tap(find.text('Images')); //Images
        await tester.pumpAndSettle();
        expect(find.text('Images'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Private Chat Info'), findsOneWidget);
        await tester.tap(find.text('Events')); //Events
        await tester.pumpAndSettle();

        expect(find.text('Events'), findsOneWidget);
        await tester.tap(find.text('Sample Event'));
        await tester.pumpAndSettle();
        expect(find.text('Sample Event'), findsOneWidget);
        expect(find.text('Event Description'), findsOneWidget);

        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Events'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Private Chat Info'), findsOneWidget);
        await tester.tap(find.text('News')); //News
        await tester.pumpAndSettle();
        expect(find.text('News'), findsOneWidget);
        expect(find.text('Title'), findsOneWidget);
        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text('Private Chat Info'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.bell), findsOneWidget);
        await tester.tap(find.byType(CupertinoSwitch));
        await tester.pumpAndSettle();
        expect(find.text('Notifications'), findsOneWidget);
      });
    });
    testWidgets(
        "Show images page renders correctly and the images are displayed correctly",
        (WidgetTester tester) async {
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('user1').set({
        'uid': 'user1',
        'name': 'name1',
        'email': 'mail1',
        'requests': [],
        'imageUrl': '',
        'surname': 'surname1',
        'username': 'username1',
        'isPublic': true,
        'token': 'token1',
        'isSignedInWithGoogle': false,
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'groups': ['123', '456'],
      });

      AuthService.setUid('user1');
      DocumentSnapshot documentSnapshot1 =
          await firestore.collection('users').doc('user1').get();

      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([fakePrivateChat2]));

      when(mockDatabaseService.getPrivateChats(any)).thenAnswer((_) {
        return Stream.value(medias);
      });
      when(mockDatabaseService.getPrivateChatIdFromMembers(['user1', 'user3']))
          .thenAnswer((_) => Stream.value('321'));

      when(mockDatabaseService.getUserDataFromUID('user1'))
          .thenAnswer((_) => Stream.value(documentSnapshot1));
      when(mockDatabaseService.getUserDataFromUID('user3')).thenAnswer((_) {
        return Stream.error('User not found');
      });
      when(mockDatabaseService.getNotification(any, any)).thenAnswer(
        (_) => Future.value(true),
      );
      when(mockDatabaseService.getPrivateMessagesType(any, Type.news))
          .thenAnswer(
        (_) => Future.value([]),
      );
      when(mockDatabaseService.getPrivateMessagesType(any, Type.image))
          .thenAnswer(
        (_) => Future.value(medias),
      );
      when(mockDatabaseService.getPrivateMessagesType(any, Type.event))
          .thenAnswer(
        (_) => Future.value([]),
      );
      when(mockDatabaseService.getUserData('user1')).thenAnswer(
          (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));

      when(mockDatabaseService.getUserData('user3')).thenAnswer((_) async {
        return Future.value(UserData.fromSnapshot(
            await firestore.collection('users').doc('user3').get()));
      });

      when(mockDatabaseService.updateNotification(any, any, any))
          .thenAnswer((_) {
        return Future.value();
      });
      when(mockDatabaseService.getUnreadMessages(any, any))
          .thenAnswer((_) => Stream.value(0));
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              userProvider.overrideWith(
                (ref, uid) async => mockDatabaseService.getUserData(uid),
              ),
              imagesPrivateChatProvider.overrideWith(
                (ref, groupId) => medias,
              ),
              eventsPrivateChatProvider.overrideWith(
                (ref, groupId) => [],
              ),
              newsPrivateChatProvider.overrideWith(
                (ref, groupId) => [],
              ),
            ],
            child: CupertinoApp(
              home: ChatPage(
                storageService: mockStorageService,
                databaseService: mockDatabaseService,
                notificationService: mockNotificationService,
                imagePicker: mockImagePicker,
              ),
            ),
          ),
        );
      });
      await tester.pumpAndSettle();
      await tester.tap(find.text('Private'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deleted Account'));
      await tester.pumpAndSettle();
      expect(find.text('Deleted Account'), findsOneWidget);

      await tester.tap(find.text('Deleted Account')); //Private Chat Info
      await tester.pumpAndSettle();

      expect(find.text('Private Chat Info'), findsOneWidget);
      expect(find.text('Deleted Account'), findsOneWidget);

      await tester.tap(find.text('Images')); //Images
      await tester.pumpAndSettle();

      expect(find.text('Images'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNWidgets(2));
      expect(find.byType(CupertinoButton), findsNWidgets(3));

      await tester.tap(find.byType(CupertinoButton).at(1)); //Media
      await tester.pumpAndSettle();

      expect(find.text("username1"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text('Images'), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsNWidgets(2));
      expect(find.byType(CupertinoButton), findsNWidgets(3));

      await tester.tap(find.byType(CupertinoButton).at(1));
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
      await tester.drag(find.text("username1"), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Deleted Account'), findsOneWidget);
      await tester.drag(find.text("Deleted Account"), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text("username1"), findsOneWidget);
    });

    testWidgets("Test edit group functionality for mobile",
        (WidgetTester tester) async {
      AuthService.setUid('user1');
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('user1').set({
        'uid': 'user1',
        'name': 'name1',
        'email': 'mail1',
        'requests': [],
        'imageUrl': '',
        'surname': 'surname1',
        'username': 'username1',
        'isPublic': true,
        'token': 'token1',
        'isSignedInWithGoogle': false,
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'groups': ['123', '456'],
      });
      await firestore.collection('users').doc('user2').set({
        'uid': 'user2',
        'name': 'name2',
        'email': 'mail2',
        'imageUrl': '',
        'surname': 'surname2',
        'username': 'username2',
        'requests': [],
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'token': 'token2',
        'isSignedInWithGoogle': false,
        'groups': ['123', '456'],
      });
      final DocumentSnapshot documentSnapshot1 =
          await firestore.collection('users').doc('user1').get();
      final DocumentSnapshot documentSnapshot2 =
          await firestore.collection('users').doc('user2').get();
      when(mockDatabaseService.getGroupRequestsForGroup(any)).thenAnswer((_) {
        return Future.value([fakeUserData1, fakeUserData2, fakeUserData3]);
      });

      when(mockDatabaseService.getGroupMessagesType(any, Type.news)).thenAnswer(
        (_) => Future.value([messages[1]]),
      );
      when(mockDatabaseService.getGroupMessagesType(any, Type.image))
          .thenAnswer(
        (_) => Future.value([messages[2]]),
      );
      when(mockDatabaseService.getGroupMessagesType(any, Type.event))
          .thenAnswer(
        (_) => Future.value([messages[3]]),
      );
      when(mockDatabaseService.getUserData('user1')).thenAnswer(
          (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
      when(mockDatabaseService.getUserData('user2')).thenAnswer(
          (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
      when(mockDatabaseService.getNotification(any, any)).thenAnswer(
        ((_) => Future.value(true)),
      );
      when(mockDatabaseService.updateGroup(any, any, any, any, any)).thenAnswer(
        ((_) => Future.value()),
      );
      when(mockDatabaseService.getGroupFromId(any)).thenAnswer(
        ((_) => Future.value(Group(
              id: '123',
              name: 'Group1',
              admin: 'user1',
              isPublic: false,
              members: [
                'user1',
                'user2',
              ],
              imagePath: '',
              description: 'Description',
              categories: ['Environment'],
              lastMessage: LastMessage(
                  recentMessage: 'Hello',
                  recentMessageSender: 'user1',
                  recentMessageTimestamp: Timestamp.fromDate(DateTime.now()),
                  recentMessageType: Type.text,
                  unreadMessages: 0,
                  sentByMe: true),
            ))),
      );
      when(mockDatabaseService.getUnreadMessages(any, any))
          .thenAnswer((_) => Stream.value(0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            requestsGroupProvider.overrideWith(
              (ref, groupId) => [fakeUserData1, fakeUserData2, fakeUserData3],
            ),
            imagesGroupProvider.overrideWith(
              (ref, groupId) => [messages[2]],
            ),
            eventsGroupProvider.overrideWith(
              (ref, groupId) => [messages[3]],
            ),
            newsGroupProvider.overrideWith(
              (ref, groupId) => [messages[1]],
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
            groupProvider.overrideWith(
              (ref, groupId) => mockDatabaseService.getGroupFromId(groupId),
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith(
              (ref, uid) async => mockDatabaseService.getUserData(uid),
            ),
          ],
          child: CupertinoApp(
            home: GroupInfoPage(
              canNavigate: false,
              groupId: fakeGroup1.id,
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Group Info'), findsOneWidget);
      expect(find.text('Group1'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Group'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Group Info'), findsOneWidget);
      expect(find.text('Group1'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(0), '');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Group name is required'), findsOneWidget);
      await tester.tap(find.text('Ok'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(0), 'Group1');
      await tester.tap(find.text('Invite Followers'));
      await tester.pumpAndSettle();
      expect(find.text("Invite Followers"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
      expect(find.text('Categories Selection'), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.lock_fill), findsOneWidget);
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.lock_open_fill), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Group Info'), findsOneWidget);
    });
    testWidgets("Test leave group functionality", (WidgetTester tester) async {
      AuthService.setUid('user1');
      final firestore = FakeFirebaseFirestore();
      await firestore.collection('users').doc('user1').set({
        'uid': 'user1',
        'name': 'name1',
        'email': 'mail1',
        'requests': [],
        'imageUrl': '',
        'surname': 'surname1',
        'username': 'username1',
        'isPublic': true,
        'token': 'token1',
        'isSignedInWithGoogle': false,
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'groups': ['123', '456'],
      });
      await firestore.collection('users').doc('user2').set({
        'uid': 'user2',
        'name': 'name2',
        'email': 'mail2',
        'imageUrl': '',
        'surname': 'surname2',
        'username': 'username2',
        'requests': [],
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'token': 'token2',
        'isSignedInWithGoogle': false,
        'groups': ['123', '456'],
      });
      final DocumentSnapshot documentSnapshot1 =
          await firestore.collection('users').doc('user1').get();
      final DocumentSnapshot documentSnapshot2 =
          await firestore.collection('users').doc('user2').get();
      when(mockDatabaseService.getGroupRequestsForGroup(any)).thenAnswer((_) {
        return Future.value([fakeUserData1, fakeUserData2, fakeUserData3]);
      });
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => Stream.value([]));
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => Stream.value([fakeGroup1]));
      when(mockDatabaseService.getUserDataFromUID('user1'))
          .thenAnswer((_) => Stream.value(documentSnapshot1));
      when(mockDatabaseService.getGroupMessagesType(any, Type.news)).thenAnswer(
        (_) => Future.value([messages[1]]),
      );
      when(mockDatabaseService.getChats(any)).thenAnswer((_) {
        return Stream.value(messages);
      });
      when(mockDatabaseService.getGroupMessagesType(any, Type.image))
          .thenAnswer(
        (_) => Future.value([messages[2]]),
      );
      when(mockDatabaseService.getGroupMessagesType(any, Type.event))
          .thenAnswer(
        (_) => Future.value([messages[3]]),
      );
      when(mockDatabaseService.getUserData('user1')).thenAnswer(
          (_) => Future.value(UserData.fromSnapshot(documentSnapshot1)));
      when(mockDatabaseService.getUserData('user2')).thenAnswer(
          (_) => Future.value(UserData.fromSnapshot(documentSnapshot2)));
      when(mockDatabaseService.getNotification(any, any)).thenAnswer(
        ((_) => Future.value(true)),
      );
      when(mockDatabaseService.toggleGroupJoin(any)).thenAnswer(
        ((_) => Future.value()),
      );
      when(mockDatabaseService.getUnreadMessages(any, any))
          .thenAnswer((_) => Stream.value(0));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupProvider.overrideWith(
              (ref, groupId) => fakeGroup1,
            ),
            requestsGroupProvider.overrideWith(
              (ref, groupId) => [fakeUserData1, fakeUserData2, fakeUserData3],
            ),
            imagesGroupProvider.overrideWith(
              (ref, groupId) => [messages[2]],
            ),
            eventsGroupProvider.overrideWith(
              (ref, groupId) => [messages[3]],
            ),
            newsGroupProvider.overrideWith(
              (ref, groupId) => [messages[1]],
            ),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            userProvider.overrideWith(
              (ref, uid) async => mockDatabaseService.getUserData(uid),
            ),
          ],
          child: CupertinoApp(
            home: ChatPage(
              databaseService: mockDatabaseService,
              notificationService: mockNotificationService,
              imagePicker: mockImagePicker,
              storageService: mockStorageService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Group1'));
      await tester.pumpAndSettle();
      expect(find.text('Group1'), findsOneWidget);
      await tester.tap(find.text('Group1'));
      await tester.pumpAndSettle();
      expect(find.text('Group Info'), findsOneWidget);
      await tester.fling(
          find.byType(SingleChildScrollView), const Offset(0, -200), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Leave Group'), findsOneWidget);
      await tester.tap(find.text('Leave Group'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Leave Group'), findsNWidgets(2));
      expect(find.text('Are you sure you want to leave this group?'),
          findsOneWidget);
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Leave Group'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text('Leave Group'), findsNWidgets(2));
      expect(find.text('Are you sure you want to leave this group?'),
          findsOneWidget);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.text('Chats'), findsOneWidget);
    });
  });
  testWidgets('InvitePage interaction and search functionality test',
      (WidgetTester tester) async {
    final mockDatabaseService = MockDatabaseService();
    final testUsers = [
      UserData(
          uid: '1',
          username: 'test_user1',
          name: 'Test1',
          surname: 'User1',
          imagePath: '',
          categories: [],
          groups: [],
          email: ''),
      UserData(
          uid: '2',
          username: 'test_user2',
          name: 'Test2',
          surname: 'User2',
          imagePath: '',
          categories: [],
          groups: [],
          email: ''),
    ];
    AuthService.setUid('test');
    List<String> users = [];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          followerProvider.overrideWith(
            (ref, uid) => Future.value(testUsers),
          ),
        ],
        child: CupertinoApp(
          home: InviteUserPage(
            invitePageKey: (String key) {
              users.add(key);
            },
            invitedUsers: users,
            id: null,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Search followers...'), findsOneWidget);
    expect(find.byType(UserInvitationTile), findsNWidgets(2));

    await tester.enterText(find.byType(CupertinoSearchTextField), 'hhhh');
    await tester.pumpAndSettle();
    expect(find.text('No followers found'), findsOneWidget);

    await tester.enterText(find.byType(CupertinoSearchTextField), 'test_user1');
    await tester.pumpAndSettle();
    expect(find.text("Invite"), findsOneWidget);
    expect(find.text("test_user1"), findsNWidgets(2));

    await tester.tap(find.text("Invite"));
    await tester.pumpAndSettle();

    expect(find.text("Invited"), findsOneWidget);
  });
  group("Shimmer Effect Tests", () {
    StreamController<List<PrivateChat>>? privateChatStreamController;
    StreamController<List<Group>>? groupStreamController;

    setUp(() {
      privateChatStreamController = StreamController<List<PrivateChat>>();
      groupStreamController = StreamController<List<Group>>();
    });

    tearDown(() {
      privateChatStreamController?.close();
      groupStreamController?.close();
    });

    testWidgets('Displays shimmer effect during private chat list loading',
        (WidgetTester tester) async {
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => groupStreamController!.stream);
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => privateChatStreamController!.stream);
      await tester.pumpWidget(
        CupertinoApp(
          home: ChatPage(
            databaseService: mockDatabaseService,
            notificationService: mockNotificationService,
            imagePicker: mockImagePicker,
            storageService: mockStorageService,
          ),
        ),
      );

      await tester.tap(find.text('Private'));
      await tester.pump();

      expect(
          find.byWidgetPredicate((widget) => widget is Shimmer), findsWidgets);
    });

    testWidgets('Displays shimmer effect during group chat list loading',
        (WidgetTester tester) async {
      when(mockDatabaseService.getGroupsStream())
          .thenAnswer((_) => groupStreamController!.stream);
      when(mockDatabaseService.getPrivateChatsStream())
          .thenAnswer((_) => privateChatStreamController!.stream);

      await tester.pumpWidget(
        CupertinoApp(
          home: ChatPage(
            databaseService: mockDatabaseService,
            notificationService: mockNotificationService,
            imagePicker: mockImagePicker,
            storageService: mockStorageService,
          ),
        ),
      );

      expect(
          find.byWidgetPredicate((widget) => widget is Shimmer), findsWidgets);
    });
  });
}
