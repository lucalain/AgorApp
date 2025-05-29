import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(
    databaseService: ref.read(databaseServiceProvider),
  );
});

final userProvider = FutureProvider.family<UserData, String>((ref, uuid) async {
  final userData = await DatabaseService().getUserData(uuid);
  return userData;
});

final notifyGroupProvider =
    FutureProvider.family<bool, String>((ref, id) async {
  try {
    final notification = await DatabaseService().getNotification(id, true);
    return notification;
  } catch (e) {
    return true;
  }
});
final notifyPrivateChatProvider =
    FutureProvider.family<bool, String>((ref, id) async {
  try {
    final notification = await DatabaseService().getNotification(id, false);
    return notification;
  } catch (e) {
    return true;
  }
});

final followerProvider =
    FutureProvider.family<List<UserData>, String>((ref, uuid) async {
  try {
    final followersSnapshot = await DatabaseService().getFollowersUser(uuid);
    final followersList =
        (followersSnapshot.data() as Map<String, dynamic>)['followers'];

    final List<UserData> followersData = [];
    for (var followerId in followersList) {
      final userData = await DatabaseService().getUserData(followerId);
      followersData.add(userData);
    }

    return followersData;
  } catch (e) {
    return [];
  }
});

final followingProvider =
    FutureProvider.family<List<UserData>, String>((ref, uuid) async {
  try {
    final followingSnapshot = await DatabaseService().getFollowersUser(uuid);
    final followingList =
        (followingSnapshot.data() as Map<String, dynamic>)['following'];

    final List<UserData> followingData = [];
    for (var followingId in followingList) {
      final userData = await DatabaseService().getUserData(followingId);
      followingData.add(userData);
    }

    return followingData;
  } catch (e) {
    return [];
  }
});

final groupsProvider =
    FutureProvider.family<List<Group>, String>((ref, uuid) async {
  try {
    final groups = await DatabaseService().getGroups(uuid);
    return groups;
  } catch (e) {
    return [];
  }
});

final newsPrivateChatProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final news = DatabaseService().getPrivateMessagesType(id, Type.news);
    return news;
  } catch (e) {
    return [];
  }
});
final eventsPrivateChatProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final events = DatabaseService().getPrivateMessagesType(id, Type.event);
    return events;
  } catch (e) {
    return [];
  }
});
final imagesPrivateChatProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final images = DatabaseService().getPrivateMessagesType(id, Type.image);
    return images;
  } catch (e) {
    return [];
  }
});

final imagesGroupProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final images = DatabaseService().getGroupMessagesType(id, Type.image);
    return images;
  } catch (e) {
    return [];
  }
});
final newsGroupProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final news = DatabaseService().getGroupMessagesType(id, Type.news);
    return news;
  } catch (e) {
    return [];
  }
});
final eventsGroupProvider =
    FutureProvider.family<List<Message>, String>((ref, id) async {
  try {
    final events = DatabaseService().getGroupMessagesType(id, Type.event);
    return events;
  } catch (e) {
    return [];
  }
});
final requestsGroupProvider =
    FutureProvider.family<List<UserData>, String>((ref, id) async {
  try {
    final requests = DatabaseService().getGroupRequestsForGroup(id);
    return requests;
  } catch (e) {
    return [];
  }
});

final joinedEventsProvider =
    FutureProvider.family<List<Event>, String>((ref, uuid) async {
  try {
    final events = await DatabaseService().getJoinedEvents(uuid);
    return events;
  } catch (e) {
    return [];
  }
});

final createdEventsProvider =
    FutureProvider.family<List<Event>, String>((ref, uuid) async {
  try {
    final events = await DatabaseService().getCreatedEvents(uuid);
    return events;
  } catch (e) {
    return [];
  }
});

final eventProvider =
    FutureProvider.family<Event, String>((ref, eventId) async {
  final event = await DatabaseService().getEvent(eventId);
  return event;
});
final groupProvider =
    FutureProvider.family<Group, String>((ref, groupId) async {
  try {
    final group = await DatabaseService().getGroupFromId(groupId);
    return group;
  } catch (e) {
    return Group(
        name: '',
        id: '',
        admin: '',
        members: [],
        isPublic: false,
        requests: []);
  }
});

final followingsStreamProvider =
    StreamProvider.family<List<dynamic>, String>((ref, uuid) {
  try {
    final stream = DatabaseService().getFollowingsStream(uuid);
    return stream;
  } catch (e) {
    return Stream.value([]);
  }
});
