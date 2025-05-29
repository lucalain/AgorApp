import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/services/database_service.dart';

class PrivateChatTileTablet extends StatelessWidget {
  final PrivateChat privateChat;
  final Function(PrivateChat) onPressed;
  final UserData other;
  final Function(DismissDirection) onDismissed;
  final DatabaseService databaseService;
  final String selectedChatId;
  PrivateChatTileTablet({
    super.key,
    required this.privateChat,
    required this.onPressed,
    required this.other,
    required this.onDismissed,
    required this.databaseService,
    required this.selectedChatId,
  });

  final Map<Type, Icon> map = {
    Type.event: const Icon(CupertinoIcons.calendar,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.news: const Icon(CupertinoIcons.news,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.image: const Icon(CupertinoIcons.photo,
        color: CupertinoColors.inactiveGray, size: 16),
  };

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
      onDismissed: onDismissed,
      child: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          onPressed(privateChat);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CreateImageUtils.getUserImage(
                    other.imagePath!,
                    0,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        other.username,
                        style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      (privateChat.lastMessage != null)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.25),
                                  child: privateChat
                                              .lastMessage!.recentMessageType !=
                                          Type.text
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              privateChat.lastMessage!
                                                          .sentByMe ==
                                                      true
                                                  ? "You: "
                                                  : "${other.username}: ",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                            map[privateChat.lastMessage!
                                                .recentMessageType]!,
                                            Text(
                                              privateChat
                                                  .lastMessage!.recentMessage,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${privateChat.lastMessage!.sentByMe == true ? "You: " : "${other.username}: "}'
                                          '${privateChat.lastMessage!.recentMessage}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.inactiveGray,
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
                ],
              ),
              (privateChat.lastMessage != null)
                  ? privateChat.id! != selectedChatId
                      ? StreamBuilder(
                          stream: databaseService.getUnreadMessages(
                              false, privateChat.id!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data == null) {
                              return const SizedBox();
                            }
                            return Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.07),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    DateTime.fromMicrosecondsSinceEpoch(privateChat
                                                    .lastMessage!
                                                    .recentMessageTimestamp
                                                    .microsecondsSinceEpoch)
                                                .isBefore(DateTime.now()) &&
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                    privateChat
                                                        .lastMessage!
                                                        .recentMessageTimestamp
                                                        .microsecondsSinceEpoch)
                                                .isAfter(DateTime.now().subtract(
                                                    const Duration(days: 1)))
                                        ? DateFormat.jm().format(
                                            DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                        : DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                            ? 'Yesterday'
                                            : DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                                ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                                : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: snapshot.data! > 0 &&
                                              privateChat.id != selectedChatId
                                          ? CupertinoTheme.of(context)
                                              .primaryColor
                                          : CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  snapshot.data! > 0 &&
                                          privateChat.id != selectedChatId
                                      ? Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
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
                              ),
                            );
                          })
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              DateTime.fromMicrosecondsSinceEpoch(privateChat
                                              .lastMessage!
                                              .recentMessageTimestamp
                                              .microsecondsSinceEpoch)
                                          .isBefore(DateTime.now()) &&
                                      DateTime.fromMicrosecondsSinceEpoch(privateChat
                                              .lastMessage!
                                              .recentMessageTimestamp
                                              .microsecondsSinceEpoch)
                                          .isAfter(DateTime.now().subtract(
                                              const Duration(days: 1)))
                                  ? DateFormat.jm().format(
                                      DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                  : DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                      ? 'Yesterday'
                                      : DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                          ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                          : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(privateChat.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.inactiveGray,
                              ),
                            ),
                          ],
                        )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
