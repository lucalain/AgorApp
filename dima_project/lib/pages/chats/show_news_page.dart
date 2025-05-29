import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/news/news_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ShowNewsPage extends ConsumerWidget {
  final bool isGroup;
  final List<Message> news;
  final String? groupId;
  final bool canNavigate;
  final Function? navigateToPage;
  final PrivateChat? privateChat;
  final UserData? user;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const ShowNewsPage(
      {super.key,
      required this.isGroup,
      required this.news,
      this.groupId,
      this.user,
      required this.canNavigate,
      required this.databaseService,
      required this.notificationService,
      this.privateChat,
      this.navigateToPage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'News',
            style: TextStyle(
                fontSize: 18, color: CupertinoTheme.of(context).primaryColor),
          ),
          leading: CupertinoNavigationBarBackButton(
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              if (isGroup) {
                ref.invalidate(groupProvider(groupId!));
              }
              if (canNavigate) {
                if (isGroup) {
                  navigateToPage!(GroupInfoPage(
                    groupId: groupId!,
                    canNavigate: canNavigate,
                    navigateToPage: navigateToPage,
                    databaseService: databaseService,
                    notificationService: notificationService,
                    imagePicker: ImagePicker(),
                  ));
                } else {
                  navigateToPage!(PrivateInfoPage(
                    privateChat: privateChat!,
                    canNavigate: canNavigate,
                    navigateToPage: navigateToPage,
                    user: user!,
                    databaseService: databaseService,
                    notificationService: notificationService,
                  ));
                }
                return;
              }
              Navigator.pop(context);
            },
          )),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final groupedMedias = DateUtil.groupMediasByDate(news);

            return ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: groupedMedias.keys.length,
              itemBuilder: (context, index) {
                String dateKey = groupedMedias.keys.elementAt(index);
                List<Message> mediasForDate = groupedMedias[dateKey]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: CupertinoTheme.of(context).primaryContrastingColor,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mediasForDate.length,
                      itemBuilder: (context, index) {
                        final message = mediasForDate[index];
                        final List<String> news = message.content.split('\n');
                        return NewsTile(
                          url: news[2],
                          description: news[1],
                          imageUrl: news[3],
                          title: news[0],
                          databaseService: databaseService,
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
