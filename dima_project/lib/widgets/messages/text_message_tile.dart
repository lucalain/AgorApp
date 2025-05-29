import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/utils/message_utils.dart';
import 'package:flutter/cupertino.dart';

class TextMessageTile extends StatelessWidget {
  final Message message;
  final String? senderUsername;
  final VoidCallback showCustomSnackbar;
  final DatabaseService databaseService;
  final FocusNode focusNode;
  const TextMessageTile({
    required this.message,
    this.senderUsername,
    required this.showCustomSnackbar,
    required this.databaseService,
    required this.focusNode,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        focusNode.unfocus();
        MessageUtils.showBottomSheet(context, message, databaseService,
            showCustomSnackbar: () => showCustomSnackbar());
      },
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: message.sentByMe! ? 24 : 0,
              right: message.sentByMe! ? 0 : 24,
            ),
            alignment: message.sentByMe!
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: message.sentByMe!
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!message.sentByMe! && message.isGroupMessage)
                  Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: CreateImageUtils.getUserImage(
                      message.senderImage!,
                      0,
                    ),
                  ),
                Flexible(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          minWidth: 80,
                        ),
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 8.0, left: 8.0, bottom: 24.0),
                        decoration: BoxDecoration(
                          borderRadius: message.sentByMe!
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                          color: message.sentByMe!
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.systemGrey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (!message.sentByMe! && message.isGroupMessage)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    senderUsername!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      letterSpacing: -0.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            Text(
                              message.content,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: message.sentByMe!
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 16,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                DateUtil.getFormattedTime(
                                    context: context,
                                    time: message.time.microsecondsSinceEpoch
                                        .toString()),
                                style: TextStyle(
                                  color: message.sentByMe!
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 8),
                              MessageUtils.buildReadByIcon(
                                message,
                                databaseService,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
