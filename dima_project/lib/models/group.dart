import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/message.dart';

class Group {
  final String name;
  final String id;
  String? admin;
  final String? imagePath;
  final String? description;
  final List<String>? categories;
  LastMessage? lastMessage;
  final List<String>? members;
  final bool isPublic;
  final List<String>? requests;
  Group({
    required this.name,
    required this.id,
    this.admin,
    this.imagePath,
    this.description,
    this.categories,
    this.lastMessage,
    this.members,
    required this.isPublic,
    this.requests,
  });

  static Map<String, dynamic> toMap(Group group) {
    return {
      'groupId': group.id,
      'groupName': group.name,
      'groupImage': group.imagePath ?? "",
      'description': group.description ?? "",
      'categories':
          group.categories?.map((category) => {'value': category}).toList(),
      'isPublic': group.isPublic,
    };
  }

  static Group fromSnapshot(DocumentSnapshot documentSnapshot) {
    return Group(
      name: documentSnapshot['groupName'],
      id: documentSnapshot['groupId'],
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['groupImage'],
      description: documentSnapshot['description'],
      categories: (documentSnapshot['categories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
      lastMessage: documentSnapshot['recentMessage'] == ""
          ? null
          : LastMessage(
              recentMessageType:
                  documentSnapshot['recentMessageType'] == 'Type.event'
                      ? Type.event
                      : documentSnapshot['recentMessageType'] == 'Type.text'
                          ? Type.text
                          : documentSnapshot['recentMessageType'] == 'Type.news'
                              ? Type.news
                              : Type.image,
              recentMessage: documentSnapshot['recentMessage'],
              recentMessageSender: documentSnapshot['recentMessageSender'],
              recentMessageTimestamp: documentSnapshot['recentMessageTime'],
            ),
      members: (documentSnapshot['members'] as List<dynamic>)
          .map((member) => member.toString())
          .toList()
          .cast<String>(),
      isPublic: documentSnapshot['isPublic'],
      requests: (documentSnapshot['requests'] as List<dynamic>)
          .map((request) => request.toString())
          .toList()
          .cast<String>(),
    );
  }
}
