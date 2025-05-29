import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/message.dart';

class LastMessage {
  final String recentMessage;
  String recentMessageSender;
  final Timestamp recentMessageTimestamp;
  final Type recentMessageType;
  int? unreadMessages;
  bool? sentByMe;
  LastMessage({
    required this.recentMessage,
    required this.recentMessageSender,
    required this.recentMessageTimestamp,
    required this.recentMessageType,
    this.unreadMessages,
    this.sentByMe,
  });
}
