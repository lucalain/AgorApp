import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/message.dart';

class PrivateChat {
  final List<String> members;
  final LastMessage? lastMessage;
  String? id;
  PrivateChat({
    required this.members,
    this.lastMessage,
    this.id,
  });

  static PrivateChat fromSnapshot(DocumentSnapshot documentSnapshot) {
    return PrivateChat(
      members: documentSnapshot['members'].cast<String>(),
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
      id: documentSnapshot.id,
    );
  }

  static PrivateChat fromMap(Map<String, dynamic> json) {
    return PrivateChat(
      members: (json['private_chat_members'] as String)
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll(' ', '')
          .split(','),
      id: json['private_chat_id'] as String,
    );
  }
}
