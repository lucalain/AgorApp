import 'package:cloud_firestore/cloud_firestore.dart';

enum Type {
  text,
  image,
  news,
  event,
}

class ReadBy {
  final String username;
  final Timestamp readAt;

  ReadBy({
    required this.username,
    required this.readAt,
  });

  toMap() {
    return {
      'username': username,
      'readAt': readAt,
    };
  }

  static ReadBy fromMap(read) {
    return ReadBy(
      username: read['username'],
      readAt: read['readAt'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ReadBy &&
        other.username == username &&
        other.readAt == readAt;
  }

  @override
  int get hashCode {
    return username.hashCode ^ readAt.hashCode;
  }
}

class Message {
  final String? id;
  final String content;
  final String sender;
  final bool? sentByMe;
  final bool isGroupMessage;
  final Timestamp time;
  final List<ReadBy>? readBy;
  final String? chatID;
  final Type type;
  String? senderImage;
  Message({
    required this.content,
    required this.sender,
    this.sentByMe,
    required this.isGroupMessage,
    required this.time,
    this.id,
    this.chatID,
    this.senderImage,
    required this.readBy,
    required this.type,
  });

  toMap() {
    return {
      'content': content,
      'sender': sender,
      'isGroupMessage': isGroupMessage,
      'time': time,
      'readBy': readBy!.map((readBy) => readBy.toMap()).toList(),
      'type': type.toString(),
      'senderImage': senderImage,
    };
  }

  static fromSnapshot(
      DocumentSnapshot snapshot, String chatID, String currentUsername) {
    return Message(
      chatID: chatID,
      content: snapshot['content'],
      sender: snapshot['sender'],
      sentByMe: snapshot['sender'] == currentUsername,
      isGroupMessage: snapshot['isGroupMessage'],
      time: snapshot['time'],
      id: snapshot.id,
      readBy: (snapshot['readBy'] as List<dynamic>)
          .map((readBy) => ReadBy(
                username: readBy['username'],
                readAt: readBy['readAt'],
              ))
          .toList()
          .cast<ReadBy>(),
      type: snapshot['type'] == 'Type.text'
          ? Type.text
          : snapshot['type'] == 'Type.news'
              ? Type.news
              : snapshot['type'] == 'Type.event'
                  ? Type.event
                  : Type.image,
      senderImage: snapshot['senderImage'],
    );
  }
}
