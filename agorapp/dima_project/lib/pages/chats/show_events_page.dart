import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ShowEventsPage extends ConsumerWidget {
  final bool isGroup;
  final List<Message> events;
  final String? groupId;
  final Function? navigateToPage;
  final bool canNavigate;
  final PrivateChat? privateChat;
  final UserData? user;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const ShowEventsPage(
      {super.key,
      required this.isGroup,
      required this.events,
      this.navigateToPage,
      required this.canNavigate,
      this.privateChat,
      required this.databaseService,
      required this.notificationService,
      this.user,
      this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Events',
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
                    navigateToPage: navigateToPage,
                    canNavigate: canNavigate,
                    user: user!,
                    databaseService: databaseService,
                    notificationService: notificationService,
                  ));
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            color: CupertinoTheme.of(context).primaryColor,
          )),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final groupedMedias = DateUtil.groupMediasByDate(events);

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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? CupertinoTheme.of(context).primaryContrastingColor
                          : CupertinoColors.black.withOpacity(0.1),
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
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: PhysicalModel(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoTheme.of(context)
                                .primaryContrastingColor,
                            child: FutureBuilder(
                              future: databaseService.getEvent(message.content),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final event = snapshot.data;
                                return GestureDetector(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          CreateImageUtils.getEventImage(
                                              event!.imagePath!, context),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                child: Text(
                                                  maxLines: 1,
                                                  event.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                child: Text(
                                                  maxLines: 3,
                                                  event.description,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) => EventPage(
                                            eventId: event.id!,
                                            imagePicker: ImagePicker(),
                                            eventService: EventService(),
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
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
