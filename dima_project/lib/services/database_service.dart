import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:synchronized/synchronized.dart';
import '../models/event.dart';

class DatabaseService {
  late final FirebaseFirestore _firestore;
  late final CollectionReference groupsRef;
  late final CollectionReference usersRef;
  late final CollectionReference followersRef;
  late final CollectionReference privateChatRef;
  late final CollectionReference eventsRef;
  late final Lock groupLock = Lock();
  late final Lock privateChatLock = Lock();
  DatabaseService() {
    _firestore = FirebaseFirestore.instance;
    groupsRef = _firestore.collection('groups');
    usersRef = _firestore.collection('users');
    followersRef = _firestore.collection('followers');
    privateChatRef = _firestore.collection('private_chats');
    eventsRef = _firestore.collection('events');
  }

  Future<void> registerUserWithUUID(
      UserData user, String uuid, Uint8List imagePath) async {
    String imageUrl = imagePath.toString() == '[]'
        ? ''
        : await StorageService()
            .uploadImageToStorage('profile_images/$uuid.jpg', imagePath);
    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await usersRef.doc(uuid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
      'groups': [],
      'privateChats': [],
      'isPublic': true,
      'token': '',
      'events': [],
      'groupsRequests': [],
      'requests': [],
      'isSignedInWithGoogle': user.isSignedInWithGoogle,
    });

    await followersRef.doc(uuid).set({
      'followers': [],
      'following': [],
    });
  }

  Future<void> updateToken(String token) async {
    debugPrint('Updating token... $token');
    await usersRef.doc(AuthService.uid).update({
      'token': token,
    });
  }

  Future<void> updateUserInformation(
    UserData user,
    Uint8List? imagePath,
    bool imageHasChanged,
    bool visibilityHasChange,
  ) async {
    if (imageHasChanged) {
      String imageUrl = imagePath.toString() == '[]' || imagePath!.isEmpty
          ? ''
          : await StorageService().uploadImageToStorage(
              'profile_images/${user.uid!}.jpg', imagePath);
      List<Map<String, dynamic>> serializedList =
          user.categories.map((item) => {'value': item}).toList();

      await usersRef.doc(user.uid).update({
        'name': user.name,
        'surname': user.surname,
        'username': user.username,
        'imageUrl': imageUrl,
        'selectedCategories': serializedList,
        'isPublic': user.isPublic,
      });
    } else {
      List<Map<String, dynamic>> serializedList =
          user.categories.map((item) => {'value': item}).toList();
      await usersRef.doc(user.uid).update({
        'name': user.name,
        'surname': user.surname,
        'username': user.username,
        'selectedCategories': serializedList,
        'isPublic': user.isPublic,
      });
    }
    if (visibilityHasChange && user.isPublic!) {
      List<dynamic> requests = (await usersRef.doc(user.uid).get())['requests'];
      if (requests.isNotEmpty) {
        for (var request in requests) {
          await toggleFollowUnfollow(user.uid!, request);
        }
        await usersRef.doc(user.uid).update({
          'requests': [],
        });
      }
    }
  }

  Future<UserData> getUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await usersRef.doc(uid).get();
      UserData user = UserData.fromSnapshot(documentSnapshot);
      return user;
    } catch (e) {
      return UserData(
          categories: [],
          email: '',
          name: '',
          surname: '',
          username: 'Deleted Account',
          imagePath: '');
    }
  }

  Stream<DocumentSnapshot<Object?>> getUserDataFromUID(String uid) {
    return usersRef.doc(uid).snapshots();
  }

  Stream<Group> getGroupFromIdStream(String id) {
    return groupsRef.doc(id).snapshots().map((snapshot) {
      return Group.fromSnapshot(snapshot);
    });
  }

  Future<Group> getGroupFromId(String id) {
    return groupsRef.doc(id).get().then((snapshot) {
      return Group.fromSnapshot(snapshot);
    });
  }

  Future<UserData> getUserDataFromUsername(String username) async {
    username = username.replaceAll('[', '').replaceAll(']', '');

    QuerySnapshot querySnapshot =
        await usersRef.where('username', isEqualTo: username).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    UserData user = UserData.fromSnapshot(documentSnapshot);
    return user;
  }

  Future<bool> checkUserExist(String email) async {
    debugPrint('Checking if user exists... $email');
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  //create a group
  Future<void> createGroup(
    Group group,
    Uint8List imagePath,
    List<String> uuids,
  ) async {
    try {
      List<Map<String, dynamic>> serializedList =
          group.categories!.map((item) => {'value': item}).toList();

      DocumentReference docRef = await groupsRef.add({
        'groupName': group.name,
        'groupImage': '',
        'admin': group.admin,
        'description': group.description,
        'groupId': '',
        'recentMessage': "",
        'recentMessageSender': "",
        'recentMessageTime': "",
        'recentMessageType': "",
        'members': FieldValue.arrayUnion([group.admin]),
        'notifications': FieldValue.arrayUnion([group.admin]),
        'categories': serializedList,
        'isPublic': group.isPublic,
        'requests': [],
      });

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService()
              .uploadImageToStorage('group_images/${docRef.id}.jpg', imagePath);

      await groupsRef.doc(docRef.id).update({
        'groupId': docRef.id,
        'groupImage': imageUrl,
      });
      await usersRef.doc(AuthService.uid).update({
        'groups': FieldValue.arrayUnion([
          docRef.id,
        ])
      });

      for (String uuid in uuids) {
        try {
          await usersRef.doc(uuid).update({
            'groupsRequests': FieldValue.arrayUnion([
              docRef.id,
            ])
          });
        } catch (e) {
          debugPrint("User doesn't exist: $uuid");
        }
      }
    } catch (e) {
      debugPrint("Error while creating the group: $e");
    }
  }

  Stream<List<Message>> getChats(String groupId) async* {
    final chats = await groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .get();

    final chatList = <Message>[];
    for (var chat in chats.docs) {
      chatList.add(Message.fromSnapshot(chat, groupId, AuthService.uid));
    }
    yield chatList; // Yield the initial list of messages

    final snapshots = groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots(); // Listen to changes in the messages collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final Message chat =
            Message.fromSnapshot(change.doc, groupId, AuthService.uid);
        chat.senderImage = '';

        if (change.type == DocumentChangeType.removed) {
          chatList.removeWhere((c) => c.id == chat.id);
          yield chatList;
        } else {
          final existingChatIndex = chatList.indexWhere((c) => c.id == chat.id);
          if (existingChatIndex != -1) {
            chatList[existingChatIndex] = chat;
          } else {
            chatList.insert(0, chat);
          }
          yield chatList;
        }
      }
    }
  }

  Stream<List<dynamic>> getGroupMembers(String groupId) {
    return groupsRef.doc(groupId).snapshots().map((snapshot) {
      return snapshot['members'];
    });
  }

  Stream<List<QueryDocumentSnapshot<Object?>>> searchByGroupNameStream(
      String searchText) {
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return groupsRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'groupName' field and convert it to lower case
        String groupName = (doc['groupName'] ?? '').toString().toLowerCase();

        // Check if the 'groupId' field is not empty
        bool validGroupId = (doc['groupId'] ?? '').toString().isNotEmpty;

        // Perform a case-insensitive substring search and check groupId
        return groupName.contains(lowerCaseSearchText) && validGroupId;
      }).toList();
    });
  }

  Stream<List<QueryDocumentSnapshot<Object?>>> searchByUsernameStream(
      String searchText) {
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return usersRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'username' field and convert it to lower case
        String username = (doc['username'] ?? '').toString().toLowerCase();

        // Perform a case-insensitive substring search
        return username.contains(lowerCaseSearchText);
      }).toList();
    });
  }

  Future<void> deleteUserGroupRequests(String groupId) async {
    QuerySnapshot<Object?> value =
        await usersRef.where("groupsRequests", arrayContains: groupId).get();
    for (var doc in value.docs) {
      await usersRef.doc(doc.id).update({
        'groupsRequests': FieldValue.arrayRemove([groupId])
      });
    }
  }

  Future<void> deleteFollowRequests() async {
    QuerySnapshot<Object?> value =
        await usersRef.where("requests", arrayContains: AuthService.uid).get();
    for (var doc in value.docs) {
      await usersRef.doc(doc.id).update({
        'requests': FieldValue.arrayRemove([AuthService.uid])
      });
    }
  }

  Future<void> deleteGroupRequests(String uid) async {
    QuerySnapshot<Object?> value =
        await groupsRef.where("requests", arrayContains: uid).get();
    for (var doc in value.docs) {
      await groupsRef.doc(doc.id).update({
        'requests': FieldValue.arrayRemove([uid])
      });
    }
  }

  Future<void> toggleGroupJoin(String groupId) async {
    DocumentSnapshot<Object?> groupDoc = await groupsRef.doc(groupId).get();
    bool isJoined = groupDoc['members'].contains(AuthService.uid);

    if (isJoined) {
      bool notify = await getNotification(groupId, true);
      if (notify) {
        await groupsRef.doc(groupId).update({
          'notifications': FieldValue.arrayRemove([AuthService.uid])
        });
      }
      await Future.wait([
        groupsRef.doc(groupId).update({
          'members': FieldValue.arrayRemove([AuthService.uid])
        }),
        usersRef.doc(AuthService.uid).update({
          'groups': FieldValue.arrayRemove([groupId])
        }),
      ]);

      DocumentSnapshot<Object?> groupDoc = await groupsRef.doc(groupId).get();
      if (groupDoc['members'].isEmpty) {
        await deleteUserGroupRequests(groupId);
        await groupsRef.doc(groupId).delete();
      } else if (groupDoc['admin'] == AuthService.uid) {
        await groupsRef.doc(groupId).update({'admin': groupDoc['members'][0]});
      }
    } else {
      if (groupDoc['isPublic']) {
        await groupsRef.doc(groupId).update({
          'notifications': FieldValue.arrayUnion([AuthService.uid])
        });
        await Future.wait([
          groupsRef.doc(groupId).update({
            'members': FieldValue.arrayUnion([AuthService.uid])
          }),
          usersRef.doc(AuthService.uid).update({
            'groups': FieldValue.arrayUnion([groupId])
          }),
          if ((await usersRef.doc(AuthService.uid).get())['groupsRequests']
              .contains(groupId))
            usersRef.doc(AuthService.uid).update({
              'groupsRequests': FieldValue.arrayRemove([groupId])
            }),
        ]);
      } else {
        if (!groupDoc['requests'].contains(AuthService.uid)) {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayUnion([AuthService.uid])
          });
        } else {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayRemove([AuthService.uid])
          });
        }
      }
    }
  }

  Future<void> sendMessage(String? id, Message message) async {
    Map<String, dynamic> messageMap = message.toMap();

    if (message.isGroupMessage) {
      await groupsRef.doc(id).collection('messages').add(messageMap);
      await groupsRef.doc(id).update({
        'recentMessage': message.type == Type.text ? message.content : 'Image',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      });
    } else {
      await privateChatRef.doc(id).collection('messages').add(messageMap);
      await privateChatRef.doc(id).update({
        'recentMessage': message.type == Type.text ? message.content : 'Image',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      });
    }
  }

  Future<PrivateChat> getPrivateChatsFromMembers(List<String> members) async {
    members.sort();
    QuerySnapshot<Object?> value =
        await privateChatRef.where("members", isEqualTo: members).get();
    if (value.docs.isEmpty) {
      return PrivateChat(members: members);
    }
    return PrivateChat.fromSnapshot(
        await privateChatRef.doc(value.docs.first.id).get());
  }

  Stream<String?> getPrivateChatIdFromMembers(List<String> members) {
    return privateChatRef.snapshots().map((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['members'].contains(members[0]) &&
            doc['members'].contains(members[1])) {
          return doc.id;
        }
      }
      return null;
    });
  }

  Future sendFirstPrivateMessage(Message message, String id) async {
    Map<String, dynamic> messageMap = message.toMap();
    return await privateChatRef.doc(id).collection('messages').add(messageMap);
  }

  Future<String> createPrivateChat(PrivateChat privateChat) async {
    List<String> members = privateChat.members;
    members.sort();
    return await privateChatRef.add({
      'members': members,
      'notifications': members,
      'recentMessage': "",
      'recentMessageSender': "",
      'recentMessageTime': "",
      'recentMessageType': "",
    }).then((value) async {
      final id = value.id;
      await usersRef.doc(members[0]).update({
        'privateChats': FieldValue.arrayUnion([id])
      });
      await usersRef.doc(members[1]).update({
        'privateChats': FieldValue.arrayUnion([id])
      });
      return id;
    });
  }

  Future<List<Group>> getGroups(String uuid) async {
    final groupIds = await usersRef.doc(uuid).get().then((value) {
      return value['groups'];
    });

    final groupsList = <Group>[];
    for (var groupId in groupIds) {
      final snapshot = await groupsRef.doc(groupId).get();
      if (snapshot.exists) {
        groupsList.add(Group.fromSnapshot(snapshot));
      }
    }
    return groupsList;
  }

  Stream<List<Group>> getGroupsStream() async* {
    final groupIds = await usersRef.doc(AuthService.uid).get().then((value) {
      return value['groups'];
    });

    final groupsList = <Group>[];
    Group group;
    for (var groupId in groupIds) {
      final snapshot = await groupsRef.doc(groupId).get();
      if (snapshot.exists) {
        group = Group.fromSnapshot(snapshot);
        if (group.lastMessage != null) {
          group.lastMessage!.sentByMe =
              group.lastMessage!.recentMessageSender == AuthService.uid;
        }
        groupsList.add(group);
      }
    }
    groupsList.sort((a, b) {
      if (a.lastMessage == null && b.lastMessage == null) {
        return 0; // Both are null, consider them equal
      } else if (a.lastMessage == null) {
        return 1; // a should come after b
      } else if (b.lastMessage == null) {
        return -1; // b should come after a
      } else {
        // Both lastMessage are not null, compare their timestamps
        return b.lastMessage!.recentMessageTimestamp
            .compareTo(a.lastMessage!.recentMessageTimestamp);
      }
    });
    yield groupsList; // yield the initial list of groups
    final snapshots =
        groupsRef.snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final groupId = change.doc.id;
        final group = Group.fromSnapshot(change.doc);
        final members = group.members;

        if (change.type == DocumentChangeType.removed) {
          groupsList.removeWhere((g) => g.id == groupId);
          yield groupsList;
        } else {
          if (members!.contains(AuthService.uid) && group.id != '') {
            if (group.lastMessage != null) {
              group.lastMessage!.sentByMe =
                  group.lastMessage!.recentMessageSender == AuthService.uid;
            }
            // DocumentChangeType.added or DocumentChangeType.modified
            final existingGroupIndex =
                groupsList.indexWhere((g) => g.id == groupId);
            if (existingGroupIndex != -1) {
              groupsList[existingGroupIndex] = group;
            } else {
              groupsList.add(group);
            }
            groupsList.sort((a, b) {
              if (a.lastMessage == null && b.lastMessage == null) {
                return 0; // Both are null, consider them equal
              } else if (a.lastMessage == null) {
                return 1; // a should come after b
              } else if (b.lastMessage == null) {
                return -1; // b should come after a
              } else {
                // Both lastMessage are not null, compare their timestamps
                return b.lastMessage!.recentMessageTimestamp
                    .compareTo(a.lastMessage!.recentMessageTimestamp);
              }
            });
            yield groupsList;
          } else {
            groupsList.removeWhere((g) => g.id == groupId);
            yield groupsList;
          }
        }
      }
    }
  }

  Stream<List<PrivateChat>> getPrivateChatsStream() async* {
    try {
      final privateChats =
          await usersRef.doc(AuthService.uid).get().then((value) {
        return value['privateChats'];
      });

      final chatsList = <PrivateChat>[];
      PrivateChat privateChat;
      for (var id in privateChats) {
        final snapshot = await privateChatRef.doc(id).get();
        if (snapshot.exists) {
          privateChat = PrivateChat.fromSnapshot(snapshot);
          try {
            privateChat.lastMessage!.sentByMe =
                privateChat.lastMessage!.recentMessageSender == AuthService.uid;

            chatsList.add(privateChat);
            // ignore: empty_catches
          } catch (e) {}
        }
      }
      chatsList.sort((a, b) {
        if (a.lastMessage == null && b.lastMessage == null) {
          return 0; // Both are null, consider them equal
        } else if (a.lastMessage == null) {
          return 1; // a should come after b
        } else if (b.lastMessage == null) {
          return -1; // b should come after a
        } else {
          // Both lastMessage are not null, compare their timestamps
          return b.lastMessage!.recentMessageTimestamp
              .compareTo(a.lastMessage!.recentMessageTimestamp);
        }
      });
      yield chatsList; // yield the initial list of private chats

      final snapshots = privateChatRef
          .snapshots(); // listen to changes in the groups collection

      await for (var snapshot in snapshots) {
        for (var change in snapshot.docChanges) {
          final id = change.doc.id;
          if (!(((change.doc.data()! as Map<String, dynamic>)['members']!
                  as List)
              .contains(AuthService.uid))) {
            continue;
          }
          privateChat = PrivateChat.fromSnapshot(change.doc);
          if (change.type == DocumentChangeType.removed) {
            chatsList.removeWhere((g) => g.id == id);
          } else {
            if (privateChat.members.contains(AuthService.uid) &&
                privateChat.lastMessage != null) {
              privateChat.lastMessage!.sentByMe =
                  privateChat.lastMessage!.recentMessageSender ==
                      AuthService.uid;

              // DocumentChangeType.added or DocumentChangeType.modified
              final existingGroupIndex =
                  chatsList.indexWhere((g) => g.id == id);
              if (existingGroupIndex != -1) {
                chatsList[existingGroupIndex] = privateChat;
              } else {
                chatsList.add(privateChat);
              }
            }
          }
          chatsList.sort((a, b) {
            if (a.lastMessage == null && b.lastMessage == null) {
              return 0; // Both are null, consider them equal
            } else if (a.lastMessage == null) {
              return 1; // a should come after b
            } else if (b.lastMessage == null) {
              return -1; // b should come after a
            } else {
              // Both lastMessage are not null, compare their timestamps
              return b.lastMessage!.recentMessageTimestamp
                  .compareTo(a.lastMessage!.recentMessageTimestamp);
            }
          });
          yield chatsList;
        }
      }
    } catch (e) {
      debugPrint('Error while getting private chats: $e');
      yield [];
    }
  }

  Future<DocumentSnapshot<Object?>> getFollowersUser(String uuid) async {
    return await followersRef.doc(uuid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getMembersStreamUser(
      String eventId, String detailId) {
    final stream =
        eventsRef.doc(eventId).collection('details').doc(detailId).snapshots();

    return stream.map((snapshot) {
      return snapshot;
    });
  }

  Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result =
        await usersRef.where('username', isEqualTo: username).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> toggleFollowUnfollow(String user, String visitor) async {
    debugPrint('Toggling follow/unfollow');

    debugPrint('User: $user');
    debugPrint('Visitor: $visitor');
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    DocumentSnapshot visitorDoc = await followersRef.doc(visitor).get();

    DocumentSnapshot doc = await usersRef.doc(user).get();

    if (!userDoc.exists || !doc.exists) {
      throw Exception('User does not exist');
    }

    // Check if the visitor is already following the user
    List<dynamic> followers = userDoc['followers'];
    List<dynamic> following = visitorDoc['following'];

    if (followers.contains(visitor)) {
      // Visitor is following the user, unfollow
      debugPrint('Visitor is following the user, unfollowing');
      followers.remove(visitor);
      following.remove(user);
      await followersRef.doc(user).update({'followers': followers});
      await followersRef.doc(visitor).update({'following': following});
    } else {
      debugPrint(doc['isPublic'].toString());
      if (doc['isPublic'] == false) {
        if (doc['requests'].contains(visitor)) {
          usersRef.doc(user).update({
            'requests': FieldValue.arrayRemove([visitor])
          });
        } else {
          usersRef.doc(user).update({
            'requests': FieldValue.arrayUnion([visitor])
          });
        }
        return;
      }

      // Visitor is not following the user, follow
      debugPrint('Visitor is not following the user, following');
      followers.add(visitor);
      following.add(user);
      await followersRef.doc(user).update({'followers': followers});
      await followersRef.doc(visitor).update({'following': following});
    }
  }

  Stream<List<Message>> getPrivateChats(String? privateChatId) async* {
    if (privateChatId == null) {
      yield [];
      return;
    }
    try {
      final chats = await privateChatRef
          .doc(privateChatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .get();

      final chatList = <Message>[];
      for (var chat in chats.docs) {
        chatList
            .add(Message.fromSnapshot(chat, privateChatId, AuthService.uid));
      }
      yield chatList; // Yield the initial list of messages

      final snapshots = privateChatRef
          .doc(privateChatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(); // Listen to changes in the messages collection

      await for (var snapshot in snapshots) {
        for (var change in snapshot.docChanges) {
          final chat =
              Message.fromSnapshot(change.doc, privateChatId, AuthService.uid);
          if (change.type == DocumentChangeType.removed) {
            chatList.removeWhere((c) => c.id == chat.id);
            yield chatList;
          } else {
            final existingChatIndex =
                chatList.indexWhere((c) => c.id == chat.id);
            if (existingChatIndex != -1) {
              chatList[existingChatIndex] = chat;
            } else {
              chatList.insert(0, chat);
            }
            yield chatList;
          }
        }
      }
    } catch (e) {
      debugPrint('Error while getting private chats: $e');
      yield [];
      return;
    }
  }

  Stream<int> getUnreadMessages(bool isGroup, String id) async* {
    if (!isGroup) {
      var snapshot = await privateChatRef.doc(id).collection('messages').get();
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        var readBy = doc.data()['readBy'] ?? {};
        // Check if the message hasn't been read by the user
        var read = false;
        for (var value in readBy) {
          if ((AuthService.uid == value['username'])) {
            read = true;
            break;
          }
        }
        if (!read) {
          unreadCount++;
        }
      }
      yield unreadCount;
      await for (var snapshot
          in privateChatRef.doc(id).collection('messages').snapshots()) {
        unreadCount = 0;
        for (var doc in snapshot.docs) {
          var readBy = doc.data()['readBy'] ?? {};
          // Check if the message hasn't been read by the user
          var read = false;
          for (var value in readBy) {
            if ((AuthService.uid == value['username'])) {
              read = true;
              break;
            }
          }
          if (!read) {
            unreadCount++;
          }
        }
        yield unreadCount;
      }
    } else {
      var snapshot = await groupsRef.doc(id).collection('messages').get();
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        var readBy = doc.data()['readBy'] ?? {};
        // Check if the message hasn't been read by the user
        var read = false;
        for (var value in readBy) {
          if ((AuthService.uid == value['username'])) {
            read = true;
            break;
          }
        }
        if (!read) {
          unreadCount++;
        }
      }
      yield unreadCount;
      await for (var snapshot
          in groupsRef.doc(id).collection('messages').snapshots()) {
        unreadCount = 0;
        for (var doc in snapshot.docs) {
          var readBy = doc.data()['readBy'] ?? {};
          // Check if the message hasn't been read by the user
          var read = false;
          for (var value in readBy) {
            if ((AuthService.uid == value['username'])) {
              read = true;
              break;
            }
          }
          if (!read) {
            unreadCount++;
          }
        }
        yield unreadCount;
      }
    }
  }

  Future<void> updateMessageReadStatus(Message message) async {
    ReadBy readBy = ReadBy(readAt: Timestamp.now(), username: AuthService.uid);

    if (message.isGroupMessage) {
      await groupLock.synchronized(() async {
        final value = await groupsRef
            .doc(message.chatID)
            .collection('messages')
            .doc(message.id)
            .get();
        final readByDoc = value['readBy'] ?? [];
        List<ReadBy> readByList = [];
        for (var read in readByDoc) {
          readByList.add(ReadBy.fromMap(read));
        }
        if (!readByList.any((element) => element.username == AuthService.uid)) {
          await groupsRef
              .doc(message.chatID)
              .collection('messages')
              .doc(message.id)
              .update({
            'readBy': FieldValue.arrayUnion([
              readBy.toMap(),
            ])
          });
        }
      });
    } else {
      await privateChatLock.synchronized(() async {
        final value = await privateChatRef
            .doc(message.chatID)
            .collection('messages')
            .doc(message.id)
            .get();
        final readByDoc = value['readBy'] ?? [];
        List<ReadBy> readByList = [];
        for (var read in readByDoc) {
          readByList.add(ReadBy.fromMap(read));
        }
        if (!readByList.any((element) => element.username == AuthService.uid)) {
          await privateChatRef
              .doc(message.chatID)
              .collection('messages')
              .doc(message.id)
              .update({
            'readBy': FieldValue.arrayUnion([
              readBy.toMap(),
            ])
          });
        }
      });
    }
  }

  Future<void> deleteMessage(Message message) async {
    if (message.isGroupMessage) {
      await groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .delete();

      final recentMessage = (await groupsRef.doc(message.chatID).get());
      if (recentMessage['recentMessage'] == message.content &&
          recentMessage['recentMessageSender'] == message.sender &&
          recentMessage['recentMessageTime'] == message.time) {
        var messagesSnapshot = await groupsRef
            .doc(message.chatID)
            .collection('messages')
            .orderBy('time', descending: false)
            .get();
        if (messagesSnapshot.docs.isNotEmpty) {
          await groupsRef.doc(message.chatID).update({
            'recentMessage': messagesSnapshot.docs.last['content'],
            'recentMessageSender': messagesSnapshot.docs.last['sender'],
            'recentMessageTime': messagesSnapshot.docs.last['time'],
            'recentMessageType': messagesSnapshot.docs.last['type'],
          });
        } else {
          await groupsRef.doc(message.chatID).update({
            'recentMessage': '',
            'recentMessageSender': '',
            'recentMessageTime': '',
            'recentMessageType': '',
          });
        }
      }
    } else {
      try {
        await privateChatRef
            .doc(message.chatID)
            .collection('messages')
            .doc(message.id)
            .delete();
        final privateChat = (await privateChatRef.doc(message.chatID).get());
        if (privateChat.exists) {
          if (privateChat['recentMessage'] == message.content &&
              privateChat['recentMessageSender'] == message.sender &&
              privateChat['recentMessageTime'] == message.time) {
            var messagesSnapshot = await privateChatRef
                .doc(message.chatID)
                .collection('messages')
                .orderBy('time', descending: false)
                .get();
            if (messagesSnapshot.docs.isNotEmpty) {
              await privateChatRef.doc(message.chatID).update({
                'recentMessage': messagesSnapshot.docs.last['content'],
                'recentMessageSender': messagesSnapshot.docs.last['sender'],
                'recentMessageTime': messagesSnapshot.docs.last['time'],
                'recentMessageType': messagesSnapshot.docs.last['type'],
              });
            } else {
              await privateChatRef.doc(message.chatID).delete();
              await usersRef.doc(privateChat['members'][0]).update({
                'privateChats': FieldValue.arrayRemove([message.chatID])
              });
              await usersRef.doc(privateChat['members'][1]).update({
                'privateChats': FieldValue.arrayRemove([message.chatID])
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error while deleting message: $e');
        debugPrint(e.toString());
      }
    }
  }

  Future<void> updateMessageContent(
      Message message, String updatedMessage) async {
    Timestamp time = Timestamp.now();
    if (message.isGroupMessage) {
      await groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      await groupsRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
        'recentMessageType': message.type.toString(),
      });
    } else {
      await privateChatRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      await privateChatRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
        'recentMessageType': message.type.toString(),
      });
    }
  }

  Future<bool> isEmailTaken(String email) async {
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Stream<List<dynamic>> getGroupRequestsStream(String id) {
    return groupsRef.doc(id).snapshots().map((snapshot) {
      return snapshot['requests'];
    });
  }

  Future<List<UserData>> getGroupRequestsForGroup(String id) async {
    final docs = await groupsRef.doc(id).get();
    List<UserData> users = [];
    for (var user in docs['requests']) {
      users.add(await getUserData(user));
    }
    return users;
  }

  Future<List<String>> getGroupRequests(String id) async {
    return (await groupsRef.doc(id).get())['requests'];
  }

  Future<List<Group>> getUserGroupRequests(String id) async {
    final doc = await usersRef.doc(id).get();
    List<Group> groups = [];
    for (var group in doc['groupsRequests']) {
      try {
        Group g = await getGroupFromId(group);
        groups.add(g);
      } catch (e) {
        debugPrint('Group does not exist');
      }
    }
    return groups;
  }

  Future<List<UserData>> getFollowRequests(String id) async {
    final docs = await usersRef.doc(id).get();
    List<UserData> users = [];
    for (var user in docs['requests']) {
      users.add(await getUserData(user));
    }
    return users;
  }

  Future<Map<String, List<dynamic>>> getEventRequests(String id) async {
    Map<String, List<dynamic>> requests = {};
    final det = await eventsRef.doc(id).collection('details').get();
    for (var detail in det.docs) {
      requests.putIfAbsent(detail.id, () => detail['requests']);
    }
    return requests;
  }

  Future<void> denyGroupRequest(String groupId, String uuid) async {
    return await groupsRef.doc(groupId).update({
      'requests': FieldValue.arrayRemove([uuid])
    });
  }

  Future<void> acceptGroupRequest(String groupId, String uuid) async {
    if ((await groupsRef.doc(groupId).get())['members']
        .contains(AuthService.uid)) {
      return;
    }
    await groupsRef.doc(groupId).update({
      'requests': FieldValue.arrayRemove([uuid])
    });
    await usersRef.doc(uuid).update({
      'groups': FieldValue.arrayUnion([groupId])
    });
    await groupsRef.doc(groupId).update({
      'members': FieldValue.arrayUnion([uuid]),
      'notifications': FieldValue.arrayUnion([uuid])
    });
    if ((await usersRef.doc(uuid).get())['groupsRequests'].contains(groupId)) {
      await usersRef.doc(uuid).update({
        'groupsRequests': FieldValue.arrayRemove([groupId])
      });
    }
  }

  Future<List<Message>> getGroupMessagesType(String id, Type type) async {
    final docs = (await groupsRef
            .doc(id)
            .collection('messages')
            .where("type", isEqualTo: type.toString())
            .orderBy('time', descending: true)
            .get())
        .docs;

    List<Message> messages = [];
    for (var doc in docs) {
      messages.add(Message.fromSnapshot(doc, id, AuthService.uid));
      if (type == Type.event) {
        //check if the event is still valid
        final event = await eventsRef.doc(doc['content']).get();
        if (!event.exists) {
          messages.removeWhere((element) => element.id == doc.id);
        }
      }
    }
    return messages;
  }

  Future<List<Message>> getPrivateMessagesType(String id, Type type) async {
    try {
      final docs = (await privateChatRef
              .doc(id)
              .collection('messages')
              .where("type", isEqualTo: type.toString())
              .orderBy('time', descending: true)
              .get())
          .docs;
      List<Message> messages = [];
      for (var doc in docs) {
        messages.add(Message.fromSnapshot(doc, id, AuthService.uid));
        if (type == Type.event) {
          //check if the event is still valid
          final event = await eventsRef.doc(doc['content']).get();
          if (!event.exists) {
            messages.removeWhere((element) => element.id == doc.id);
          }
        }
      }
      return messages;
    } catch (e) {
      debugPrint("Not possible to get messages for chat $id");
      return [];
    }
  }

  Future<void> acceptUserRequest(
    String user,
  ) async {
    await usersRef.doc(AuthService.uid).update({
      'requests': FieldValue.arrayRemove([user])
    });
    await Future.wait([
      followersRef.doc(AuthService.uid).update({
        'followers': FieldValue.arrayUnion([user])
      }),
      followersRef.doc(user).update({
        'following': FieldValue.arrayUnion([AuthService.uid])
      }),
    ]);
  }

  Future<void> denyUserRequest(
    String user,
  ) async {
    await usersRef.doc(AuthService.uid).update({
      'requests': FieldValue.arrayRemove([user])
    });
  }

  Future<void> denyEventRequest(
      String eventId, String detailId, String uuid) async {
    if ((await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .get())['requests']
        .contains(uuid)) {
      await eventsRef.doc(eventId).collection('details').doc(detailId).update({
        'requests': FieldValue.arrayRemove([uuid])
      });
    }
  }

  Future<void> acceptEventRequest(
      String eventId, String detailId, String uid) async {
    if ((await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .get())['members']
        .contains(uid)) {
      if ((await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .get())['requests']
          .contains(uid)) {
        await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .update({
          'requests': FieldValue.arrayRemove([uid])
        });
      }
      throw Exception('User is already a member of the event');
    }

    await usersRef.doc(uid).update({
      'events': FieldValue.arrayUnion(["$eventId:$detailId"])
    });
    await eventsRef.doc(eventId).collection('details').doc(detailId).update({
      'members': FieldValue.arrayUnion([uid]),
    });
    if ((await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .get())['requests']
        .contains(uid)) {
      eventsRef.doc(eventId).collection('details').doc(detailId).update({
        'requests': FieldValue.arrayRemove([uid])
      });
    }
  }

  Future<void> denyUserGroupRequest(String groupId) async {
    await usersRef.doc(AuthService.uid).update({
      'groupsRequests': FieldValue.arrayRemove([groupId])
    });
  }

  Future<void> acceptUserGroupRequest(
    String groupId,
  ) async {
    await usersRef.doc(AuthService.uid).update({
      'groupsRequests': FieldValue.arrayRemove([groupId])
    });
    if ((await groupsRef.doc(groupId).get())['members']
        .contains(AuthService.uid)) {
      return;
    }
    await usersRef.doc(AuthService.uid).update({
      'groups': FieldValue.arrayUnion([groupId])
    });
    await Future.wait([
      groupsRef.doc(groupId).update({
        'members': FieldValue.arrayUnion([AuthService.uid]),
      }),
      usersRef.doc(AuthService.uid).update({
        'groupsRequests': FieldValue.arrayRemove([groupId])
      }),
      if ((await groupsRef.doc(groupId).get())['requests']
          .contains(AuthService.uid))
        groupsRef.doc(groupId).update({
          'requests': FieldValue.arrayRemove([groupId])
        }),
    ]);
  }

  Future<void> createEvent(Event event, Uint8List imagePath, List<String> uuids,
      List<String> groupIds) async {
    try {
      DocumentReference docRef = await eventsRef.add(Event.toMap(event));

      for (EventDetails details in event.details!) {
        await docRef.collection('details').add(EventDetails.toMap(details));
      }

      //get ids from the details
      final docs = await docRef.collection('details').get();

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService()
              .uploadImageToStorage('event_images/${docRef.id}.jpg', imagePath);

      await eventsRef.doc(docRef.id).update({
        'imagePath': imageUrl,
        'eventId': docRef.id,
        'createdAt': Timestamp.now(),
      });

      for (var doc in docs.docs) {
        await usersRef.doc(AuthService.uid).update({
          'events': FieldValue.arrayUnion([
            '${docRef.id}:${doc.id}',
          ])
        });
      }
      if (groupIds.isNotEmpty) {
        await sendEventsToGroups(docRef.id, groupIds);
      }
      if (uuids.isNotEmpty) {
        await sendEventsToPrivateChats(docRef.id, uuids);
      }
    } catch (e) {
      debugPrint("Error while creating the event: $e");
    }
  }

  Future<void> sendEventsToGroups(String eventId, List<String> groupIds) async {
    Message message = Message(
      content: eventId,
      sender: AuthService.uid,
      isGroupMessage: true,
      time: Timestamp.now(),
      type: Type.event,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );
    for (var id in groupIds) {
      try {
        await groupsRef.doc(id).collection('messages').add(
              message.toMap(),
            );
        await groupsRef.doc(id).update({
          'recentMessage': 'Event',
          'recentMessageSender': message.sender,
          'recentMessageTime': message.time,
          'recentMessageType': message.type.toString(),
        });
        await NotificationService(databaseService: this).sendGroupNotification(
          id,
          message,
        );
      } catch (e) {
        debugPrint('Group does not exist');
      }
    }
  }

  Future<void> sendEventsToPrivateChats(
      String eventId, List<String> uuids) async {
    Message message = Message(
      content: eventId,
      sender: AuthService.uid,
      isGroupMessage: false,
      time: Timestamp.now(),
      type: Type.event,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );

    for (var uuid in uuids) {
      try {
        final PrivateChat privateChat =
            await getPrivateChatsFromMembers([uuid, AuthService.uid]);
        if (privateChat.id == null) {
          final id = await createPrivateChat(privateChat);
          privateChat.id = id;
        }
        await Future.wait([
          privateChatRef.doc(privateChat.id).collection('messages').add(
                message.toMap(),
              ),
          privateChatRef.doc(privateChat.id).update({
            'recentMessage': 'Event',
            'recentMessageSender': message.sender,
            'recentMessageTime': message.time,
            'recentMessageType': message.type.toString(),
          }),
          NotificationService(databaseService: this)
              .sendPrivateChatNotification(
            privateChat,
            message,
          ),
        ]);
      } catch (e) {
        debugPrint('User does not exist');
      }
    }
  }

  Stream<List<QueryDocumentSnapshot<Object?>>> searchByEventNameStream(
      String searchText) {
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return eventsRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'name' field and convert it to lower case
        String eventName = (doc['name'] ?? '').toString().toLowerCase();

        // Check if the 'eventId' field is not empty
        bool validEventId = (doc['eventId'] ?? '').toString().isNotEmpty;

        // Perform a case-insensitive substring search and check eventId
        return eventName.contains(lowerCaseSearchText) && validEventId;
      }).toList();
    });
  }

  Future<void> toggleEventJoin(
    String eventId,
    String detailId,
  ) async {
    DocumentSnapshot<Object?> eventDoc;
    DocumentSnapshot<Map<String, dynamic>> detailDoc;
    try {
      eventDoc = await eventsRef.doc(eventId).get();
      detailDoc = await eventsRef
          .doc(eventId)
          .collection('details')
          .doc(detailId)
          .get();
    } catch (e) {
      throw Exception('Event or date has been deleted');
    }
    if (!eventDoc.exists || !detailDoc.exists) {
      throw Exception('Event or date has been deleted');
    }
    if (!DateTime.now().isBefore(DateTime(
      detailDoc['startDate'].toDate().year,
      detailDoc['startDate'].toDate().month,
      detailDoc['startDate'].toDate().day,
      detailDoc['startDate'].toDate().hour,
      detailDoc['startDate'].toDate().minute,
    ))) {
      throw Exception('Event has already started');
    }
    try {
      debugPrint('Event ID: $eventId');
      bool isJoined = detailDoc['members'].contains(AuthService.uid);
      debugPrint('Is joined: $isJoined');
      if (isJoined) {
        await Future.wait([
          eventsRef.doc(eventId).collection('details').doc(detailId).update({
            'members': FieldValue.arrayRemove([AuthService.uid])
          }),
          usersRef.doc(AuthService.uid).update({
            'events': FieldValue.arrayRemove(["$eventId:$detailId"])
          }),
        ]);
      } else {
        if (eventDoc['isPublic']) {
          await Future.wait([
            eventsRef.doc(eventId).collection('details').doc(detailId).update({
              'members': FieldValue.arrayUnion([AuthService.uid])
            }),
            usersRef.doc(AuthService.uid).update({
              'events': FieldValue.arrayUnion(["$eventId:$detailId"])
            }),
          ]);
        } else {
          if (!detailDoc['requests'].contains(AuthService.uid)) {
            await eventsRef
                .doc(eventId)
                .collection('details')
                .doc(detailId)
                .update({
              'requests': FieldValue.arrayUnion([AuthService.uid])
            });
          } else {
            await eventsRef
                .doc(eventId)
                .collection('details')
                .doc(detailId)
                .update({
              'requests': FieldValue.arrayRemove([AuthService.uid])
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error while joining event: $e');
      throw Exception('Event or date has been deleted');
    }
  }

  Stream<Event> getEventStream(String eventId) {
    // Assuming you're using Firestore or any other database service
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists) {
        return await Event.fromSnapshot(snapshot);
      } else {
        throw Exception('Event not found');
      }
    });
  }

  Future<List<Event>> getCreatedEvents(String uuid) async {
    final ids = await usersRef.doc(uuid).get().then((value) {
      return value['events'];
    });
    final eventsIds = [];
    ids.forEach((element) {
      eventsIds.add(element.split(':')[0]);
    });

    final eventsList = <Event>[];

    for (var eventId in eventsIds) {
      final snapshot = await eventsRef.doc(eventId).get();
      if (snapshot.exists) {
        Event event = await Event.fromSnapshot(snapshot);
        if (event.admin == uuid &&
            !eventsList.any((element) => element.id == event.id)) {
          eventsList.add(event);
        }
      }
    }
    eventsList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return eventsList;
  }

  Future<List<Event>> getJoinedEvents(String uuid) async {
    final ids = await usersRef.doc(uuid).get().then((value) {
      return value['events'];
    });
    final eventsIds = [];
    ids.forEach((element) {
      eventsIds.add(element.split(':')[0]);
    });
    final eventsList = <Event>[];

    for (var eventId in eventsIds) {
      final snapshot = await eventsRef.doc(eventId).get();
      if (snapshot.exists) {
        Event event = await Event.fromSnapshot(snapshot);
        if (event.admin != uuid &&
            !eventsList.any((element) => element.id == event.id)) {
          eventsList.add(event);
        }
      }
    }
    eventsList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return eventsList;
  }

  Future shareNewsWithGroup(String title, String description, String imageUrl,
      String blogUrl, String id) async {
    Message message = Message(
      content: '$title\n$description\n$blogUrl\n$imageUrl',
      sender: AuthService.uid,
      isGroupMessage: true,
      time: Timestamp.now(),
      type: Type.news,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );
    return await Future.wait([
      groupsRef.doc(id).collection('messages').add(
            message.toMap(),
          ),
      groupsRef.doc(id).update({
        'recentMessage': 'News',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      }),
      NotificationService(databaseService: this).sendGroupNotification(
        id,
        message,
      ),
    ]);
  }

  Future shareNewsWithFollower(
    String title,
    String description,
    String imageUrl,
    String blogUrl,
    String uid,
  ) async {
    Message message = Message(
      content: '$title\n$description\n$blogUrl\n$imageUrl',
      sender: AuthService.uid,
      isGroupMessage: false,
      time: Timestamp.now(),
      type: Type.news,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );
    try {
      final PrivateChat privateChat = await getPrivateChatsFromMembers(
          [uid, FirebaseAuth.instance.currentUser!.uid]);

      if (privateChat.id == null) {
        final id = await createPrivateChat(privateChat);
        privateChat.id = id;
      }
      return await Future.wait([
        privateChatRef.doc(privateChat.id).collection('messages').add(
              message.toMap(),
            ),
        privateChatRef.doc(privateChat.id).update({
          'recentMessage': 'News',
          'recentMessageSender': message.sender,
          'recentMessageTime': message.time,
          'recentMessageType': message.type.toString(),
        }),
        NotificationService(databaseService: this).sendPrivateChatNotification(
          privateChat,
          message,
        ),
      ]);
    } catch (e) {
      debugPrint(
          'Not possible to share news on follower since user does not exist');
    }
  }

  Future<void> updateEvent(
    Event event,
    Uint8List? uint8list,
    bool sameImage,
    bool visibilityHasChanged,
  ) async {
    await eventsRef.doc(event.id).update(Event.toMap(event));

    for (EventDetails detail in event.details!) {
      if (detail.id == null) {
        await eventsRef.doc(event.id).collection('details').add({
          'startDate': DateTime(
              detail.startDate!.year,
              detail.startDate!.month,
              detail.startDate!.day,
              detail.startTime!.hour,
              detail.startTime!.minute),
          'endDate': DateTime(
              detail.endDate!.year,
              detail.endDate!.month,
              detail.endDate!.day,
              detail.endTime!.hour,
              detail.endTime!.minute),
          'location': detail.location,
          'latlng': GeoPoint(detail.latlng!.latitude, detail.latlng!.longitude),
          'members': detail.members,
          'requests': detail.requests ?? [],
        });
      } else {
        await eventsRef
            .doc(event.id)
            .collection('details')
            .doc(detail.id)
            .update({
          'startDate': DateTime(
              detail.startDate!.year,
              detail.startDate!.month,
              detail.startDate!.day,
              detail.startTime!.hour,
              detail.startTime!.minute),
          'endDate': DateTime(
              detail.endDate!.year,
              detail.endDate!.month,
              detail.endDate!.day,
              detail.endTime!.hour,
              detail.endTime!.minute),
          'location': detail.location,
          'latlng': GeoPoint(detail.latlng!.latitude, detail.latlng!.longitude),
        });
      }
    }

    if (!sameImage) {
      String imageUrl = uint8list.toString() == '[]' || uint8list!.isEmpty
          ? ''
          : await StorageService()
              .uploadImageToStorage('event_images/${event.id}.jpg', uint8list);
      await eventsRef.doc(event.id).update({
        'imagePath': imageUrl,
      });
    }

    List<String> members = [];
    for (EventDetails detail in event.details!) {
      members.addAll(detail.members!);
    }
    try {
      if (visibilityHasChanged && event.isPublic) {
        Map<String, List<dynamic>> requests = await getEventRequests(event.id!);
        for (var key in requests.keys) {
          List<dynamic> ids = requests[key]!;
          for (var id in ids) {
            try {
              await acceptEventRequest(event.id!, key, id);
            } catch (e) {
              debugPrint('User is already a member of the event');
            }
            members.add(id);
          }
        }
      }
    } catch (e) {
      debugPrint('Error while accepting event requests: $e');
    }
  }

  Future<Event> getEvent(String id) {
    return eventsRef.doc(id).get().then((value) {
      return Event.fromSnapshot(value);
    });
  }

  updateGroup(Group group, Uint8List? uint8list, bool sameImage,
      bool visibilityHasChanged, List<String> uuids) async {
    await groupsRef.doc(group.id).update(Group.toMap(group));

    if (!sameImage) {
      String imageUrl = uint8list.toString() == '[]' || uint8list!.isEmpty
          ? ''
          : await StorageService()
              .uploadImageToStorage('group_images/${group.id}.jpg', uint8list);
      await groupsRef.doc(group.id).update({
        'groupImage': imageUrl,
      });
    }
    List<dynamic> members = await groupsRef.doc(group.id).get().then((value) {
      return value['members'];
    });
    if (visibilityHasChanged && group.isPublic) {
      List<dynamic> requests = await getGroupRequests(group.id);
      for (var id in requests) {
        await acceptGroupRequest(group.id, id);
        members.add(id);
      }
    }

    await inviteUserToGroup(group.id, uuids, members);
  }

  Future<void> inviteUserToGroup(
      String groupId, List<String> uids, List<dynamic> members) async {
    try {
      for (var id in uids) {
        if (!members.contains(id)) {
          final user = await usersRef.doc(id).get();

          if (user.exists && !user['groupsRequests'].contains(groupId)) {
            try {
              await usersRef.doc(id).update({
                'groupsRequests': FieldValue.arrayUnion([groupId])
              });
            } catch (e) {
              debugPrint('User does not exist');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error while inviting user to group: $e');
    }
  }

  Future<void> deletePrivateChat(PrivateChat chat) async {
    await privateChatRef.doc(chat.id!).delete();
    try {
      await usersRef.doc(chat.members[0]).update({
        'privateChats': FieldValue.arrayRemove([chat.id])
      });
    } catch (e) {
      debugPrint("User doesn't exists: ${chat.members[0]}");
    }
    try {
      await usersRef.doc(chat.members[1]).update({
        'privateChats': FieldValue.arrayRemove([chat.id])
      });
    } catch (e) {
      debugPrint("User doesn't exists:${chat.members[1]}");
    }
  }

  Future<void> deleteDetail(String eventId, String detailId) async {
    final details =
        await eventsRef.doc(eventId).collection('details').doc(detailId).get();

    details['members'].forEach((element) async {
      await usersRef.doc(element).update({
        'events': FieldValue.arrayRemove(["$eventId:$detailId"])
      });
    });

    await eventsRef.doc(eventId).collection('details').doc(detailId).delete();

    debugPrint('Detail deleted');

    if ((await eventsRef.doc(eventId).collection('details').get())
        .docs
        .isEmpty) {
      await eventsRef.doc(eventId).delete();
    }
  }

  Future<void> deleteEvent(String eventId) async {
    final details = await eventsRef.doc(eventId).collection('details').get();
    for (var detail in details.docs) {
      await deleteDetail(eventId, detail.id);
    }
    await eventsRef.doc(eventId).delete();
  }

  Future<void> deleteUser() async {
    final userDoc = await usersRef.doc(AuthService.uid).get();
    //exit all groups
    for (var group in userDoc['groups']) {
      await toggleGroupJoin(
        group,
      );
    }
    deleteGroupRequests(AuthService.uid);
    deleteEventRequests(AuthService.uid);
    //exit all events
    for (var event in userDoc['events']) {
      final eventId = event.split(':')[0];
      final detailId = event.split(':')[1];

      final docEvent = await eventsRef.doc(eventId).get();
      if (docEvent.exists && docEvent['admin'] == AuthService.uid) {
        await deleteEvent(eventId);
      } else {
        final doc = await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .get();

        if (doc.exists) {
          await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .update({
            'members': FieldValue.arrayRemove([AuthService.uid])
          });
        }
      }
    }
    final followerDoc = await followersRef.doc(AuthService.uid).get();

    //exit all following
    for (var following in followerDoc['following']) {
      await toggleFollowUnfollow(following, AuthService.uid);
    }
    //exit all followers
    for (var follower in followerDoc['followers']) {
      await toggleFollowUnfollow(AuthService.uid, follower);
    }
    await deleteFollowRequests();
    await followersRef.doc(AuthService.uid).delete();

    //delete user
    await usersRef.doc(AuthService.uid).delete();
  }

  Future<String> getDeviceTokenPrivateChat(PrivateChat chat) async {
    final chatDoc = await privateChatRef.doc(chat.id).get();

    // Retrieve and convert notifications to List<String>
    final List<dynamic> notificationsDynamic = chatDoc['notifications'] ?? [];
    final List<String> notifications = List<String>.from(notificationsDynamic);

    final String otherUID =
        chat.members[0] == AuthService.uid ? chat.members[1] : chat.members[0];
    if (!notifications.contains(otherUID)) {
      return '';
    }
    return (await usersRef.doc(otherUID).get())['token'];
  }

  Future<List<String>> getDevicesTokensGroup(String groupId) async {
    final groupDoc = await groupsRef.doc(groupId).get();
    final List<dynamic> notificationsDynamic = groupDoc['notifications'];
    final List<String> notifications = List<String>.from(notificationsDynamic);

    final List<String> tokens = [];
    for (var notification in notifications) {
      if (notification != AuthService.uid) {
        tokens.add((await usersRef.doc(notification).get())['token']);
      }
    }
    return tokens;
  }

  Future<List<String>> getDevicesTokensDetail(
      String eventId, String detailId) async {
    List<String> tokens = [];

    final List<String> members = List<String>.from((await eventsRef
        .doc(eventId)
        .collection('details')
        .doc(detailId)
        .get())["members"]);

    members.remove(AuthService.uid);

    for (String member in members) {
      tokens.add((await usersRef.doc(member).get())["token"]);
    }

    return tokens;
  }

  Future<List<String>> getDevicesTokensEvent(String eventId) async {
    final detailDocs = await eventsRef.doc(eventId).collection('details').get();

    final Set<String> uniqueMembers = {};

    for (var detailDoc in detailDocs.docs) {
      final List<dynamic> currentMembersDynamic = detailDoc['members'] ?? [];

      final List<String> currentMembers =
          List<String>.from(currentMembersDynamic);
      uniqueMembers.addAll(currentMembers);
    }

    final List<String> tokens = [];
    uniqueMembers.remove(AuthService.uid);
    for (var member in uniqueMembers) {
      tokens.add((await usersRef.doc(member).get())['token']);
    }

    return tokens;
  }

  Stream<List<dynamic>> getFollowingsStream(String uuid) {
    return followersRef.doc(uuid).snapshots().map((snapshot) {
      return snapshot['following'];
    });
  }

  Future<void> updateNotification(String id, bool notify, bool isGroup) async {
    if (!isGroup) {
      if (notify) {
        await privateChatRef.doc(id).update({
          'notifications': FieldValue.arrayUnion([AuthService.uid])
        });
      } else {
        await privateChatRef.doc(id).update({
          'notifications': FieldValue.arrayRemove([AuthService.uid])
        });
      }
    } else {
      if (notify) {
        await groupsRef.doc(id).update({
          'notifications': FieldValue.arrayUnion([AuthService.uid])
        });
      } else {
        await groupsRef.doc(id).update({
          'notifications': FieldValue.arrayRemove([AuthService.uid])
        });
      }
    }
  }

  Future<bool> getNotification(String id, bool isGroup) async {
    if (isGroup) {
      return groupsRef.doc(id).get().then((value) {
        return value['notifications'].contains(AuthService.uid);
      });
    } else {
      return privateChatRef.doc(id).get().then((value) {
        return value['notifications'].contains(AuthService.uid);
      });
    }
  }

  Future<void> updateGroupMessagesReadStatus(String id) async {
    final ReadBy readBy = ReadBy(
      readAt: Timestamp.now(),
      username: AuthService.uid,
    );
    await groupLock.synchronized(() async {
      await groupsRef.doc(id).collection('messages').get().then((value) async {
        for (var doc in value.docs) {
          final readByDoc = doc['readBy'] ?? [];
          List<ReadBy> readByList = [];
          for (var read in readByDoc) {
            readByList.add(ReadBy.fromMap(read));
          }
          if (!readByList
              .any((element) => element.username == AuthService.uid)) {
            await groupsRef.doc(id).collection('messages').doc(doc.id).update({
              'readBy': FieldValue.arrayUnion([
                readBy.toMap(),
              ])
            });
          }
        }
      });
    });
  }

  Future<void> updatePrivateChatMessagesReadStatus(String? id) async {
    if (id == null) return;
    final ReadBy readBy = ReadBy(
      readAt: Timestamp.now(),
      username: AuthService.uid,
    );
    await privateChatLock.synchronized(() async {
      await privateChatRef.doc(id).collection('messages').get().then((value) {
        for (var doc in value.docs) {
          final readByDoc = doc['readBy'] ?? [];
          List<ReadBy> readByList = [];
          for (var read in readByDoc) {
            readByList.add(ReadBy.fromMap(read));
          }
          if (!readByList
              .any((element) => element.username == AuthService.uid)) {
            privateChatRef.doc(id).collection('messages').doc(doc.id).update({
              'readBy': FieldValue.arrayUnion([
                readBy.toMap(),
              ])
            });
          }
        }
      });
    });
  }

  Future<void> deleteEventRequests(String uid) async {
    await eventsRef.get().then((value) {
      for (var doc in value.docs) {
        eventsRef.doc(doc.id).collection('details').get().then((value) {
          for (var detail in value.docs) {
            if (detail['requests'].contains(uid)) {
              eventsRef
                  .doc(doc.id)
                  .collection('details')
                  .doc(detail.id)
                  .update({
                'requests': FieldValue.arrayRemove([uid])
              });
            }
          }
        });
      }
    });
  }
}
