import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';
import 'package:intl/intl.dart';

class GroupChatTileTablet extends StatelessWidget {
  final Group group;
  final Function(Group) onPressed;
  final String username;
  final Function(DismissDirection) onDismissed;
  final DatabaseService databaseService;
  final String selectedGroupId;
  GroupChatTileTablet({
    super.key,
    required this.group,
    required this.onPressed,
    required this.username,
    required this.onDismissed,
    required this.databaseService,
    required this.selectedGroupId,
  });

  final Map<Type, Icon> map = {
    Type.event: const Icon(CupertinoIcons.calendar,
        color: CupertinoColors.inactiveGray, size: 14),
    Type.news: const Icon(CupertinoIcons.news,
        color: CupertinoColors.inactiveGray, size: 14),
    Type.image: const Icon(CupertinoIcons.photo,
        color: CupertinoColors.inactiveGray, size: 14),
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
          onPressed(group);
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
                  CreateImageUtils.getGroupImage(group.imagePath!, small: true),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.2),
                        child: Text(
                          maxLines: 2,
                          group.name,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 2),
                      (group.lastMessage != null)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.25),
                                  child: group.lastMessage!.recentMessageType !=
                                          Type.text
                                      ? Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              group.lastMessage!.sentByMe ==
                                                      true
                                                  ? "You: "
                                                  : "$username: ",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                            map[group.lastMessage!
                                                .recentMessageType]!,
                                            Text(
                                              group.lastMessage!.recentMessage,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: CupertinoColors
                                                    .inactiveGray,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          '${group.lastMessage!.sentByMe == true ? "You: " : "$username: "}'
                                          '${group.lastMessage!.recentMessage}',
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
              (group.lastMessage != null)
                  ? selectedGroupId != group.id
                      ? StreamBuilder(
                          stream:
                              databaseService.getUnreadMessages(true, group.id),
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
                                    DateTime.fromMicrosecondsSinceEpoch(group
                                                    .lastMessage!
                                                    .recentMessageTimestamp
                                                    .microsecondsSinceEpoch)
                                                .isBefore(DateTime.now()) &&
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                    group
                                                        .lastMessage!
                                                        .recentMessageTimestamp
                                                        .microsecondsSinceEpoch)
                                                .isAfter(DateTime.now().subtract(
                                                    const Duration(days: 1)))
                                        ? DateFormat.jm().format(
                                            DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                        : DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                            ? 'Yesterday'
                                            : DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                                ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                                : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: snapshot.data! > 0 &&
                                              group.id != selectedGroupId
                                          ? CupertinoTheme.of(context)
                                              .primaryColor
                                          : CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  snapshot.data! > 0 &&
                                          group.id != selectedGroupId
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
                              DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                          .isBefore(DateTime.now()) &&
                                      DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now()
                                          .subtract(const Duration(days: 1)))
                                  ? DateFormat.jm().format(DateTime.fromMicrosecondsSinceEpoch(group
                                      .lastMessage!
                                      .recentMessageTimestamp
                                      .microsecondsSinceEpoch))
                                  : DateTime.fromMicrosecondsSinceEpoch(group
                                              .lastMessage!
                                              .recentMessageTimestamp
                                              .microsecondsSinceEpoch)
                                          .isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                      ? 'Yesterday'
                                      : DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                          ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                          : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.inactiveGray,
                              ),
                            )
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
