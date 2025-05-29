import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/image_view_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ShowImagesPage extends ConsumerWidget {
  final bool isGroup;
  final List<Message> medias;
  final bool canNavigate;
  final Function? navigateToPage;
  final String? groupId;
  final PrivateChat? privateChat;
  final UserData? user;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const ShowImagesPage(
      {super.key,
      required this.isGroup,
      required this.medias,
      required this.canNavigate,
      this.privateChat,
      this.user,
      this.groupId,
      this.navigateToPage,
      required this.databaseService,
      required this.notificationService});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Images',
            style: TextStyle(
                fontSize: 18, color: CupertinoTheme.of(context).primaryColor),
          ),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () {
              if (isGroup) {
                ref.invalidate(groupProvider(groupId!));
              }
              if (canNavigate) {
                if (isGroup) {
                  ref.invalidate(groupProvider(groupId!));

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
              } else {
                Navigator.of(context).pop();
              }
            },
            color: CupertinoTheme.of(context).primaryColor,
          )),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final groupedMedias = DateUtil.groupMediasByDate(medias);
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
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemPink,
                              ),
                            ),
                          ]),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: mediasForDate.length,
                      itemBuilder: (context, index) {
                        final message = mediasForDate[index];
                        return Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: message.content,
                              fit: BoxFit.cover,
                              width: 180,
                              height: 180,
                              errorWidget: (context, url, error) =>
                                  const Icon(CupertinoIcons.photo_fill),
                              errorListener: (value) {},
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              left: 0,
                              top: 0,
                              child: CupertinoButton(
                                  child: const SizedBox.shrink(),
                                  onPressed: () {
                                    if (canNavigate) {
                                      navigateToPage!(ImageViewPage(
                                        isGroup: isGroup,
                                        groupId: groupId,
                                        privateChat: privateChat,
                                        user: user,
                                        canNavigate: canNavigate,
                                        navigateToPage: navigateToPage,
                                        media: message,
                                        messages: groupedMedias.values
                                            .expand((element) => element)
                                            .toList(),
                                        databaseService: databaseService,
                                        notificationService:
                                            notificationService,
                                      ));
                                    } else {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => ImageViewPage(
                                            isGroup: isGroup,
                                            groupId: groupId,
                                            user: user,
                                            privateChat: privateChat,
                                            canNavigate: canNavigate,
                                            navigateToPage: navigateToPage,
                                            media: message,
                                            messages: groupedMedias.values
                                                .expand((element) => element)
                                                .toList(),
                                            databaseService: databaseService,
                                            notificationService:
                                                notificationService,
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                            ),
                          ],
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
