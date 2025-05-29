import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/chats/show_events_page.dart';
import 'package:dima_project/pages/chats/show_images_page.dart';
import 'package:dima_project/pages/chats/show_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/widgets/notification_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PrivateInfoPage extends ConsumerStatefulWidget {
  final PrivateChat privateChat;
  final Function? navigateToPage;
  final bool canNavigate;
  final UserData user;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const PrivateInfoPage({
    super.key,
    required this.privateChat,
    this.navigateToPage,
    required this.canNavigate,
    required this.user,
    required this.databaseService,
    required this.notificationService,
  });

  @override
  PrivateInfoPageState createState() => PrivateInfoPageState();
}

class PrivateInfoPageState extends ConsumerState<PrivateInfoPage> {
  final String uid = AuthService.uid;
  late final DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = widget.databaseService;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Message>> images =
        ref.watch(imagesPrivateChatProvider(widget.privateChat.id!));
    final AsyncValue<List<Message>> news =
        ref.watch(newsPrivateChatProvider(widget.privateChat.id!));
    final AsyncValue<List<Message>> events =
        ref.watch(eventsPrivateChatProvider(widget.privateChat.id!));
    final AsyncValue<bool> notify =
        ref.watch(notifyPrivateChatProvider(widget.privateChat.id!));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(PrivateChatPage(
                storageService: StorageService(),
                privateChat: widget.privateChat,
                canNavigate: widget.canNavigate,
                navigateToPage: widget.navigateToPage,
                user: widget.user,
                databaseService: widget.databaseService,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
              ));
              return;
            }
            Navigator.of(context).pop();
          },
        ),
        middle: Text("Private Chat Info",
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CreateImageUtils.getUserImage(
                                  widget.user.imagePath!, 1),
                              const SizedBox(width: 20),
                              Text(
                                widget.user.username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.user.name} ${widget.user.surname}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor,
                        ),
                        child: Column(
                          children: [
                            CupertinoListTile(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Images"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  images.when(
                                      loading: () => const SizedBox(),
                                      error: (error, stack) => const Text(
                                            "Error",
                                          ),
                                      data: (data) {
                                        return data.isEmpty
                                            ? const SizedBox()
                                            : Text(
                                                data.length.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: CupertinoColors
                                                      .opaqueSeparator,
                                                ),
                                              );
                                      }),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                images.when(
                                  loading: () => (),
                                  error: (error, stack) => (),
                                  data: (data) {
                                    if (widget.canNavigate) {
                                      widget.navigateToPage!(ShowImagesPage(
                                        privateChat: widget.privateChat,
                                        medias: data,
                                        canNavigate: true,
                                        navigateToPage: widget.navigateToPage,
                                        isGroup: false,
                                        user: widget.user,
                                        databaseService: _databaseService,
                                        notificationService:
                                            widget.notificationService,
                                      ));
                                      return;
                                    }
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowImagesPage(
                                          privateChat: widget.privateChat,
                                          canNavigate: false,
                                          isGroup: false,
                                          medias: data,
                                          user: widget.user,
                                          databaseService: _databaseService,
                                          notificationService:
                                              widget.notificationService,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator
                                  .withOpacity(0.2),
                            ),
                            CupertinoListTile(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Events"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  events.when(
                                      loading: () => const SizedBox(),
                                      error: (error, stack) =>
                                          const Text('Error'),
                                      data: (data) {
                                        return data.isEmpty
                                            ? const SizedBox()
                                            : Text(
                                                data.length.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: CupertinoColors
                                                      .opaqueSeparator,
                                                ),
                                              );
                                      }),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                events.when(
                                  loading: () => (),
                                  error: (error, stack) => (),
                                  data: (data) {
                                    if (widget.canNavigate) {
                                      widget.navigateToPage!(ShowEventsPage(
                                        privateChat: widget.privateChat,
                                        events: data,
                                        canNavigate: true,
                                        navigateToPage: widget.navigateToPage,
                                        isGroup: false,
                                        user: widget.user,
                                        databaseService: _databaseService,
                                        notificationService:
                                            widget.notificationService,
                                      ));
                                      return;
                                    }

                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowEventsPage(
                                          privateChat: widget.privateChat,
                                          canNavigate: false,
                                          isGroup: false,
                                          events: data,
                                          user: widget.user,
                                          databaseService: _databaseService,
                                          notificationService:
                                              widget.notificationService,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator
                                  .withOpacity(0.2),
                            ),
                            CupertinoListTile(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.news,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("News"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  news.when(
                                      loading: () => const SizedBox(),
                                      error: (error, stack) =>
                                          const Text('Error'),
                                      data: (data) {
                                        return data.isEmpty
                                            ? const SizedBox()
                                            : Text(
                                                data.length.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: CupertinoColors
                                                      .opaqueSeparator,
                                                ),
                                              );
                                      }),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                news.when(
                                  loading: () => (),
                                  error: (error, stack) => (),
                                  data: (data) {
                                    if (widget.canNavigate) {
                                      widget.navigateToPage!(ShowNewsPage(
                                        privateChat: widget.privateChat,
                                        news: data,
                                        canNavigate: true,
                                        navigateToPage: widget.navigateToPage,
                                        isGroup: false,
                                        user: widget.user,
                                        databaseService: _databaseService,
                                        notificationService:
                                            widget.notificationService,
                                      ));
                                      return;
                                    }

                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowNewsPage(
                                          privateChat: widget.privateChat,
                                          canNavigate: false,
                                          isGroup: false,
                                          news: data,
                                          user: widget.user,
                                          databaseService: _databaseService,
                                          notificationService:
                                              widget.notificationService,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator
                                  .withOpacity(0.2),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: notify.when(
                                loading: () => const SizedBox.shrink(),
                                error: (error, stack) => const Text("Error"),
                                data: (data) => NotificationWidget(
                                    notify: data,
                                    notifyFunction: (value) async {
                                      await _databaseService.updateNotification(
                                          widget.privateChat.id!, value, false);
                                      ref.invalidate(notifyPrivateChatProvider(
                                          widget.privateChat.id!));
                                    }),
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
          ),
        ),
      ),
    );
  }
}
