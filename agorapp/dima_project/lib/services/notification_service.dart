import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/news/category_news.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:dima_project/models/message.dart' as chat_message;
import 'package:image_picker/image_picker.dart';

class NotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late final DatabaseService databaseService;
  static final List<String> topics = [];
  static const categoryToTopicMap = {
    "Environment": "Environment",
    "Cooking": "Cooking",
    "Culture": "Culture",
    "Film & TV Series": "Film",
    "Books": "Books",
    "Gossip": "Gossip",
    "Music": "Music",
    "Politics": "Politics",
    "Health & Wellness": "Health",
    "School & Education": "School",
    "Sports": "Sports",
    "Technology": "Technology",
    "Volunteering": "Volunteering"
  };
  NotificationService({required this.databaseService});

  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('user granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('user provisional permission');
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }
  }

  void initLocalNotifications(BuildContext context, RemoteMessage message,
      Function changeIndex, Function clearNavigatorKeys) async {
    var initializationSettings = const InitializationSettings(
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message, changeIndex, clearNavigatorKeys);
    });
  }

  void firebaseInit(
      BuildContext context, Function changeIndex, Function clearNavigatorKeys) {
    FirebaseMessaging.onMessage.listen((message) {
      forgroundMessage();
      initLocalNotifications(context, message, changeIndex, clearNavigatorKeys);
    });
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    debugPrint(token);
    return token!;
  }

  Future<void> setupToken(WidgetRef ref) async {
    String? token = await FirebaseMessaging.instance.getToken();
    await databaseService.updateToken(token!);

    messaging.onTokenRefresh.listen((event) async {
      if (FirebaseAuth.instance.currentUser == null) {
        return;
      }
      await databaseService.updateToken(event);
      ref.invalidate(userProvider(AuthService.uid));
    });
  }

  Future<void> setUpInteractMessage(BuildContext context, Function changeIndex,
      Function clearNavigatorKeys) async {
    //when app is terminated
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('initialMessage');
      if (!context.mounted) return;
      handleMessage(context, initialMessage, changeIndex, clearNavigatorKeys);
    }

    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('onMessageOpenedApp');
      handleMessage(context, message, changeIndex, clearNavigatorKeys);
    });
  }

  Future<void> handleMessage(BuildContext context, RemoteMessage message,
      Function changeIndex, Function clearNavigatorKeys) async {
    debugPrint('handleMessage');
    debugPrint(message.data.toString());
    //handle notification function
    if (message.data['type'] == 'private_chat') {
      final PrivateChat privateChat =
          PrivateChat.fromMap(Map<String, dynamic>.from(message.data));

      final String other = privateChat.members
          .firstWhere((element) => element != AuthService.uid);
      final UserData user = await DatabaseService().getUserData(other);
      if (!context.mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      clearNavigatorKeys();
      changeIndex(1, null, privateChat, user);
      if (MediaQuery.of(context).size.width > Constants.limitWidth) {
        return;
      }
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => PrivateChatPage(
                  storageService: StorageService(),
                  privateChat: privateChat,
                  user: user,
                  canNavigate: false,
                  databaseService: DatabaseService(),
                  notificationService: NotificationService(
                    databaseService: DatabaseService(),
                  ),
                  imagePicker: ImagePicker())));
    }
    if (message.data['type'] == 'group_chat') {
      final Group group =
          await DatabaseService().getGroupFromId(message.data['group_id']);
      if (!context.mounted) return;

      Navigator.popUntil(context, (route) => route.isFirst);
      clearNavigatorKeys();
      changeIndex(1, group, null, null);

      if (MediaQuery.of(context).size.width > Constants.limitWidth) {
        return;
      }

      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => GroupChatPage(
                    storageService: StorageService(),
                    groupId: group.id,
                    canNavigate: false,
                    databaseService: DatabaseService(),
                    notificationService:
                        NotificationService(databaseService: DatabaseService()),
                    imagePicker: ImagePicker(),
                    eventService: EventService(),
                  )));
    }
    if (message.data['type'] == 'event' &&
        message.notification!.body == "Event has been modified") {
      Navigator.popUntil(context, (route) => route.isFirst);
      clearNavigatorKeys();
      changeIndex(4, null, null, null);
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => EventPage(
                    eventId: message.data['event_id'],
                    imagePicker: ImagePicker(),
                    eventService: EventService(),
                  )));
    }
    if (message.data['type'].toString() == 'news') {
      try {
        Navigator.popUntil(context, (route) => route.isFirst);
        clearNavigatorKeys();
        changeIndex(0, null, null, null);

        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CategoryNews(
                      name: message.data['category'].toString(),
                      newsService: NewsService(),
                      databaseService: DatabaseService(),
                    )));
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future forgroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "dima-58cb8",
      "private_key_id": "907497455d3525c930ddd1b9adbb891df78c19d1",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCzdO6yIAodmHF2\nfTSW3psoIktQj6qTAlwUThBp2nBNDNiC42IOTJB9CMkYO/F6o/H8BK6FDZqAS7CD\nmQB+HriW3AzH09oN/f1R9hafphxPIlZ9SG+sZm6zBghoeVsuC7WZq440yzRYf20s\n7ubwT7NR2ALUXOJwhIFKm8yzVI6RZNb4zZicbMQaRPMhWmcH/ffxg5lyRVXoNe4d\nYGOUqwBYnR0j89xol+amzficTj+qPvQpOt+HS9UHFVSDLHMus08cz+ZMMfDIqNbT\nfPPk0IpFDSCvqZ8QZHdP2jgxVfpRyRS0gddm1pafGNnKTFRiFiG/rtdJuHJAhdfB\nDOm2dAHpAgMBAAECggEAANIiqxxyrxnOBq+/uL+SYT3r4OsFYpPZ3IuU5xBhv8R5\nc1AvqvoYLYEyXcK+IoNQ7NPgGVV/qQBBaC/zBRASClGmHMLhPwVEkdW6ilZGLtHG\n9Di67FUcGCn/+8pHRv/ySR5tF3kLB3vSP1zXFqNKZIx0A6zJM4QqKWq/vfVli7s8\nTgpVKcQDCDU2BppzhsMlcZ/KaqWK1VYGuiGtrnU6uwiysVxzGgiWaoh/xNARMfB3\nb8yIfRAe/jDjc8C6wyoBk0Eu6/7lramSA3PvmKSc4mCOVrS/hKXYGEk4TZtmK4Ky\nFGGvhVLlUurB8aK3ckMmggkZwsPp8O84pKu4t4hPtQKBgQDWomCwJLUYMV7AfUTS\ned9U8z3dwhUFF3iEhYN6VYz9bLxCEY+dQsiTeo8xVfJY6WtMdIMPbjziwsd/dUhL\nyunsBt0W7/7QMna9m2nUFb2aGd8j3zgQuQFUYx337vFCt6WCGxS11QOehKVCuTSN\nHZ3OgIeVonO2Hyl4ZbJ2GLb7jQKBgQDWCveGGneQxiDugPrAJ9tb55dvvIcThNCe\n74yK3+jxQsMIhSfXt+LySK5kvHPqy9aNYIfWtJTHGFqBC21XT+ZUQhiFBUtjerX8\nKdhcxzem/qw7zTrwOGGwDfAyfX585Wm4gSE9pf7rIxJ04TIOPvR+GpF5xITSTjcB\n2ZMyF7FazQKBgFJJstQVXrDFzNPzsv0W6H7DOwbYMALhurzkC0JNpl5K3+pcnTjn\nr8qLBHcfwmhAJXkMemriEsnFb4L4Th1w0DpDb2Qp4wGjN07+VJaRNz3riVdRb0dK\nBq55ybWSkEDJ89Rr2YbVAiw2Ir3wD6vCnQvczx6ZR8+dJuMX6lHIq+7JAoGAeoAk\nUffr3kvGpTnkSP2Gqf7NyQFZPW6SB6SKByFHLG1NOh8bQnbXyFqYlMbWgNbQoHFS\nzSrky13AzoI/vezYofiCF/+DuheM+Bjq346U51pyMHew97MNFbmkcwEn10tlSld9\nMs9CKkkUUxhfkY+uVk3WXJ6AdeyVxtVDTTQKKTECgYBnoAdZp/2AdCd84gpO4BBs\ndTgbHFbcZYbTUdErh+51XYr8vOBBZHgfMr1YUAg4sym6XLYka+K+8tQEzJco9jyv\nWsGavUhyAtS9gAtCyxeWo0PshWIsg/4uu6H/IGdcuL0pjHypJye+g0O8dkQQlch0\nP4KDVQh0QFmfXYS9UNRMZw==\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-notification@dima-58cb8.iam.gserviceaccount.com",
      "client_id": "114105969686402355633",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-notification%40dima-58cb8.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    final List<String> scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/firebase.database',
    ];
    http.Client client = await auth.clientViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);
    client.close();
    return credentials.accessToken.data;
  }

  Future<void> sendPrivateChatNotification(
      PrivateChat privateChat, chat_message.Message chatMessage) async {
    String deviceToken =
        await DatabaseService().getDeviceTokenPrivateChat(privateChat);
    if (deviceToken == '') return;
    final String serverAccessTokenKey = await getAccessToken();
    const endpoint =
        'https://fcm.googleapis.com/v1/projects/dima-58cb8/messages:send';
    final String username =
        (await DatabaseService().getUserData(AuthService.uid)).username;
    final String content = chatMessage.type == chat_message.Type.text
        ? chatMessage.content.length > 20
            ? '${chatMessage.content.substring(0, 20)}...'
            : chatMessage.content
        : chatMessage.type == chat_message.Type.image
            ? 'Image'
            : chatMessage.type == chat_message.Type.event
                ? 'Event'
                : 'News';

    Map<String, dynamic> message = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": username,
          "body": content,
        },
        "data": {
          "type": "private_chat",
          "private_chat_id": privateChat.id,
          "private_chat_members": privateChat.members.toString(),
        },
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpoint),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $serverAccessTokenKey',
      },
      body: jsonEncode(message),
    );
    if (response.statusCode == 200) {
      debugPrint('Notification sent');
    } else {
      debugPrint('Notification not sent');
    }
  }

  Future<void> sendGroupNotification(
      String groupId, chat_message.Message chatMessage) async {
    List<String> devicesTokens =
        await DatabaseService().getDevicesTokensGroup(groupId);
    final String groupName =
        (await DatabaseService().getGroupFromId(groupId)).name;
    if (devicesTokens == []) return;
    final String serverAccessTokenKey = await getAccessToken();
    const endpoint =
        'https://fcm.googleapis.com/v1/projects/dima-58cb8/messages:send';

    final String username =
        (await DatabaseService().getUserData(AuthService.uid)).username;
    final String content = chatMessage.type == chat_message.Type.text
        ? chatMessage.content.length > 20
            ? '${chatMessage.content.substring(0, 20)}...'
            : chatMessage.content
        : chatMessage.type == chat_message.Type.image
            ? 'Image'
            : chatMessage.type == chat_message.Type.event
                ? 'Event'
                : 'News';
    for (String deviceToken in devicesTokens) {
      if (deviceToken == '') continue;
      Map<String, dynamic> message = {
        "message": {
          "token": deviceToken,
          "notification": {
            "title": groupName,
            "body": "$username: $content",
          },
          "data": {
            "type": "group_chat",
            "group_id": groupId,
          },
        }
      };

      final http.Response response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $serverAccessTokenKey',
        },
        body: jsonEncode(message),
      );
      debugPrint(response.body);
      if (response.statusCode == 200) {
        debugPrint('Notification sent');
      } else {
        debugPrint('Notification not sent');
      }
    }
  }

  Future<void> sendEventNotification(
      String eventName, String eventId, bool detail, String detailId) async {
    List<String> devicesTokens = [];
    if (detail) {
      devicesTokens =
          await DatabaseService().getDevicesTokensDetail(eventId, detailId);
    } else {
      devicesTokens = await DatabaseService().getDevicesTokensEvent(eventId);
    }
    if (devicesTokens == []) return;
    final String serverAccessTokenKey = await getAccessToken();
    const endpoint =
        'https://fcm.googleapis.com/v1/projects/dima-58cb8/messages:send';

    final String content = detail
        ? 'A date has been deleted'
        : detailId == '1'
            ? 'Event has been modified'
            : 'Event has been deleted';

    for (String deviceToken in devicesTokens) {
      if (deviceToken == '') continue;
      Map<String, dynamic> message = {
        "message": {
          "token": deviceToken,
          "notification": {
            "title": eventName,
            "body": content,
          },
          "data": {
            "type": "event",
            "event_id": eventId,
          },
        }
      };

      final http.Response response = await http.post(
        Uri.parse(endpoint),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $serverAccessTokenKey',
        },
        body: jsonEncode(message),
      );
      if (response.statusCode == 200) {
        debugPrint('Notification sent');
      } else {
        debugPrint('Notification not sent');
      }
    }
  }

  Future<void> subscribeToTopics() async {
    List<String> categories =
        (await databaseService.getUserData(AuthService.uid)).categories;
    for (String category in categories) {
      if (!topics.contains(category)) {
        topics.add(category);
        await messaging.subscribeToTopic(categoryToTopicMap[category]!);
      }
    }
  }

  Future<void> updateTopicSubscriptions(List<String> newCategories) async {
    List<String> oldCategories = topics.toList();
    for (String category in oldCategories) {
      if (!newCategories.contains(category)) {
        await messaging.unsubscribeFromTopic(categoryToTopicMap[category]!);
        topics.remove(category);
      }
    }

    for (String category in newCategories) {
      if (!oldCategories.contains(category)) {
        await messaging.subscribeToTopic(categoryToTopicMap[category]!);
        topics.add(category);
      }
    }
  }

  Future<void> unsubscribeAndClearTopics() async {
    for (String category in topics) {
      await messaging.unsubscribeFromTopic(categoryToTopicMap[category]!);
    }
    topics.clear();
  }

  Future<void> initialize(BuildContext context, WidgetRef ref,
      Function changeIndex, Function clearNavigatorKeys) async {
    await requestNotificationPermission();
    await forgroundMessage();
    if (!context.mounted) return;
    firebaseInit(context, changeIndex, clearNavigatorKeys);
    await setUpInteractMessage(context, changeIndex, clearNavigatorKeys);
    await setupToken(ref);
    await subscribeToTopics();
  }
}
