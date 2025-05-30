import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/utils/message_utils.dart';
import 'package:flutter/cupertino.dart';

class NewsMessageTile extends StatelessWidget {
  final Message message;
  final String? senderUsername;
  final DatabaseService databaseService;
  const NewsMessageTile({
    required this.message,
    this.senderUsername,
    required this.databaseService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => MessageUtils.showBottomSheet(
        context,
        message,
        databaseService,
        showCustomSnackbar: null,
      ),
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
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
                Container(
                  margin: message.sentByMe!
                      ? const EdgeInsets.only(left: 30)
                      : const EdgeInsets.only(right: 30),
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 10),
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
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final List<String> news =
                                  message.content.split('\n');
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ArticleView(
                                    blogUrl: news[2],
                                    description: news[1],
                                    imageUrl: news[3],
                                    title: news[0],
                                    databaseService: databaseService,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    message.content.split('\n').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Text(
                                    message.content.split('\n')[1],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                CreateImageUtils.getImage(
                                  message.content.split('\n')[3],
                                  message.sentByMe!,
                                  small: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            right: message.sentByMe! ? 8 : null,
            left: message.sentByMe!
                ? null
                : message.isGroupMessage
                    ? MediaQuery.of(context).size.width > Constants.limitWidth
                        ? 195
                        : MediaQuery.of(context).size.width / 2
                    : MediaQuery.of(context).size.width > Constants.limitWidth
                        ? 150
                        : MediaQuery.of(context).size.width / 2 - 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtil.getFormattedTime(
                      context: context,
                      time: message.time.microsecondsSinceEpoch.toString()),
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
        ],
      ),
    );
  }
}
