import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PrivateChatTile extends StatefulWidget {
  final PrivateChat privateChat;
  final UserData other;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  final StorageService storageService;
  const PrivateChatTile({
    super.key,
    required this.privateChat,
    required this.other,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
    required this.storageService,
  });

  @override
  PrivateChatTileState createState() => PrivateChatTileState();
}

class PrivateChatTileState extends State<PrivateChatTile> {
  Map<Type, Icon> map = {
    Type.event: const Icon(CupertinoIcons.calendar,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.news: const Icon(CupertinoIcons.news,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.image: const Icon(CupertinoIcons.photo,
        color: CupertinoColors.inactiveGray, size: 16),
  };
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.systemRed,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        child: const Icon(
          CupertinoIcons.trash,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) async {
        await widget.databaseService.deletePrivateChat(widget.privateChat);
      },
      child: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () async {
          setState(() {
            widget.privateChat.lastMessage!.unreadMessages = 0;
          });
          widget.databaseService
              .updatePrivateChatMessagesReadStatus(widget.privateChat.id!);
          if (!context.mounted) return;
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => PrivateChatPage(
                storageService: widget.storageService,
                privateChat: widget.privateChat,
                canNavigate: false,
                user: widget.other,
                databaseService: widget.databaseService,
                notificationService: widget.notificationService,
                imagePicker: widget.imagePicker,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CreateImageUtils.getUserImage(
                    widget.other.imagePath!,
                    0,
                  ),
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.other.username,
                          style: TextStyle(
                              color: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        (widget.privateChat.lastMessage != null)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6),
                                    child: widget.privateChat.lastMessage!
                                                .recentMessageType !=
                                            Type.text
                                        ? Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.privateChat.lastMessage!
                                                            .sentByMe ==
                                                        true
                                                    ? "You: "
                                                    : "${widget.other.username}: ",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: CupertinoColors
                                                      .inactiveGray,
                                                ),
                                              ),
                                              map[widget
                                                  .privateChat
                                                  .lastMessage!
                                                  .recentMessageType]!,
                                              Text(
                                                widget.privateChat.lastMessage!
                                                    .recentMessage,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: CupertinoColors
                                                      .inactiveGray,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            '${widget.privateChat.lastMessage!.sentByMe == true ? "You: " : "${widget.other.username}: "}'
                                            '${widget.privateChat.lastMessage!.recentMessage}',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color:
                                                  CupertinoColors.inactiveGray,
                                            ),
                                          ),
                                  )
                                ],
                              )
                            : const Text(
                                "Join the conversation!",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.inactiveGray),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              (widget.privateChat.lastMessage != null)
                  ? StreamBuilder(
                      stream: widget.databaseService
                          .getUnreadMessages(false, widget.privateChat.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data == null) {
                          return const SizedBox();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                          .isBefore(DateTime.now()) &&
                                      DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now()
                                          .subtract(const Duration(days: 1)))
                                  ? DateFormat.jm().format(DateTime.fromMicrosecondsSinceEpoch(widget
                                      .privateChat
                                      .lastMessage!
                                      .recentMessageTimestamp
                                      .microsecondsSinceEpoch))
                                  : DateTime.fromMicrosecondsSinceEpoch(widget
                                              .privateChat
                                              .lastMessage!
                                              .recentMessageTimestamp
                                              .microsecondsSinceEpoch)
                                          .isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                      ? 'Yesterday'
                                      : DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                          ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                          : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(widget.privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                              style: TextStyle(
                                fontSize: 12,
                                color: snapshot.data! > 0
                                    ? CupertinoTheme.of(context).primaryColor
                                    : CupertinoColors.inactiveGray,
                              ),
                            ),
                            const SizedBox(height: 1),
                            snapshot.data! > 0
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      snapshot.data!.toString(),
                                      style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 12),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        );
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
