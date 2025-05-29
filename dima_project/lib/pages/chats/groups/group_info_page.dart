import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/groups/add_members_group_page.dart';
import 'package:dima_project/pages/chats/groups/edit_group_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/groups/group_requests_page.dart';
import 'package:dima_project/pages/chats/show_events_page.dart';
import 'package:dima_project/pages/chats/show_images_page.dart';
import 'package:dima_project/pages/chats/show_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/notification_widget.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class GroupInfoPage extends ConsumerStatefulWidget {
  final String groupId;
  final Function? navigateToPage;
  final bool canNavigate;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  const GroupInfoPage({
    super.key,
    required this.groupId,
    this.navigateToPage,
    required this.canNavigate,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
  });

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends ConsumerState<GroupInfoPage> {
  final String uid = AuthService.uid;
  late final DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = widget.databaseService;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Group> asyncValue =
        ref.watch(groupProvider(widget.groupId));

    final AsyncValue<List<Message>> images =
        ref.watch(imagesGroupProvider(widget.groupId));
    final AsyncValue<List<Message>> news =
        ref.watch(newsGroupProvider(widget.groupId));
    final AsyncValue<List<Message>> events =
        ref.watch(eventsGroupProvider(widget.groupId));
    final AsyncValue<List<UserData>> requests =
        ref.watch(requestsGroupProvider(widget.groupId));
    final AsyncValue<bool> notify =
        ref.watch(notifyGroupProvider(widget.groupId));
    return asyncValue.when(
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => const Text("Error"),
        data: (group) {
          final List<AsyncValue<UserData>> members = [];
          for (var member in group.members!) {
            members.add(ref.watch(userProvider(member)));
          }
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false,
              transitionBetweenRoutes: false,
              leading: CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(GroupChatPage(
                      storageService: StorageService(),
                      groupId: widget.groupId,
                      canNavigate: widget.canNavigate,
                      navigateToPage: widget.navigateToPage,
                      databaseService: _databaseService,
                      notificationService: widget.notificationService,
                      imagePicker: ImagePicker(),
                      eventService: EventService(),
                    ));
                    return;
                  }
                  Navigator.of(context).pop();
                },
              ),
              middle: Text(
                "Group Info",
                style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontSize: 18.0),
              ),
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              trailing: group.admin == uid
                  ? CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () async {
                        if (widget.canNavigate) {
                          widget.navigateToPage!(EditGroupPage(
                            group: group,
                            canNavigate: true,
                            navigateToPage: widget.navigateToPage,
                            imagePicker: widget.imagePicker,
                          ));
                          return;
                        }
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => EditGroupPage(
                                      group: group,
                                      canNavigate: false,
                                      imagePicker: widget.imagePicker,
                                    )));
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              primary: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CreateImageUtils.getGroupImage(
                                group.imagePath!,
                              ),
                              const SizedBox(width: 20),
                              Text(
                                group.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: group.categories!
                                .map((category) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            CategoryUtil.iconForCategory(
                                                category),
                                            size: 24,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            category,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: CupertinoTheme.of(context)
                                                  .textTheme
                                                  .textStyle
                                                  .color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Description: ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  group.description!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
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
                                if (!group.isPublic && group.admin == uid)
                                  CupertinoListTile(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    title: Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.square_list,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text("Requests"),
                                      ],
                                    ),
                                    trailing: Row(
                                      children: [
                                        requests.when(
                                            loading: () =>
                                                const SizedBox.shrink(),
                                            error: (error, stack) =>
                                                const Text("Error"),
                                            data: (data) {
                                              return (data.isEmpty)
                                                  ? const SizedBox()
                                                  : Text(
                                                      data.length.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color: CupertinoColors
                                                            .opaqueSeparator,
                                                      ),
                                                    );
                                            }),
                                        const SizedBox(width: 10),
                                        Icon(
                                          CupertinoIcons.right_chevron,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      requests.when(
                                        loading: () => (),
                                        error: (error, stack) => (),
                                        data: (data) async {
                                          if (widget.canNavigate) {
                                            widget.navigateToPage!(
                                                GroupRequestsPage(
                                              groupId: group.id,
                                              requests: data,
                                              canNavigate: widget.canNavigate,
                                              navigateToPage:
                                                  widget.navigateToPage,
                                              notificationService:
                                                  widget.notificationService,
                                              databaseService: _databaseService,
                                            ));
                                            return;
                                          }

                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  GroupRequestsPage(
                                                groupId: group.id,
                                                requests: data,
                                                canNavigate: widget.canNavigate,
                                                notificationService:
                                                    widget.notificationService,
                                                databaseService:
                                                    _databaseService,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                if (!group.isPublic && group.admin == uid)
                                  Container(
                                    height: 1,
                                    color: CupertinoColors.opaqueSeparator
                                        .withOpacity(0.2),
                                  ),
                                CupertinoListTile(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Images"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      images.when(
                                          loading: () =>
                                              const SizedBox.shrink(),
                                          error: (error, stack) =>
                                              const Text("Error"),
                                          data: (medias) {
                                            return (medias.isEmpty)
                                                ? const SizedBox()
                                                : Text(
                                                    medias.length.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: CupertinoColors
                                                          .opaqueSeparator,
                                                    ),
                                                  );
                                          }),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    images.when(
                                      loading: () => (),
                                      error: (error, stack) => (),
                                      data: (medias) {
                                        if (widget.canNavigate) {
                                          widget.navigateToPage!(ShowImagesPage(
                                            isGroup: true,
                                            medias: medias,
                                            canNavigate: true,
                                            navigateToPage:
                                                widget.navigateToPage,
                                            groupId: group.id,
                                            databaseService: _databaseService,
                                            notificationService:
                                                widget.notificationService,
                                          ));
                                          return;
                                        }
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                ShowImagesPage(
                                              isGroup: true,
                                              medias: medias,
                                              groupId: group.id,
                                              canNavigate: false,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.calendar,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Events"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      events.when(
                                          loading: () =>
                                              const SizedBox.shrink(),
                                          error: (error, stack) =>
                                              const Text("Error"),
                                          data: (data) {
                                            return data.isEmpty
                                                ? const SizedBox()
                                                : Text(
                                                    data.length.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: CupertinoColors
                                                          .opaqueSeparator,
                                                    ),
                                                  );
                                          }),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
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
                                            groupId: group.id,
                                            isGroup: true,
                                            events: data,
                                            canNavigate: true,
                                            navigateToPage:
                                                widget.navigateToPage,
                                            databaseService: _databaseService,
                                            notificationService:
                                                widget.notificationService,
                                          ));
                                          return;
                                        }
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                ShowEventsPage(
                                              groupId: group.id,
                                              canNavigate: false,
                                              isGroup: true,
                                              events: data,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.news,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("News"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      news.when(
                                          loading: () =>
                                              const SizedBox.shrink(),
                                          error: (error, stack) =>
                                              const Text("Error"),
                                          data: (data) {
                                            return (data.isEmpty)
                                                ? const SizedBox()
                                                : Text(
                                                    data.length.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: CupertinoColors
                                                          .opaqueSeparator,
                                                    ),
                                                  );
                                          }),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
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
                                            groupId: group.id,
                                            isGroup: true,
                                            news: data,
                                            canNavigate: true,
                                            navigateToPage:
                                                widget.navigateToPage,
                                            databaseService: _databaseService,
                                            notificationService:
                                                widget.notificationService,
                                          ));
                                          return;
                                        }
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) => ShowNewsPage(
                                              groupId: group.id,
                                              canNavigate: false,
                                              isGroup: true,
                                              news: data,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: notify.when(
                                    loading: () => const SizedBox.shrink(),
                                    error: (error, stack) =>
                                        const Text("Error"),
                                    data: (data) => NotificationWidget(
                                        notify: data,
                                        notifyFunction: (value) async {
                                          await _databaseService
                                              .updateNotification(
                                                  widget.groupId, value, true);
                                          ref.invalidate(notifyGroupProvider(
                                              widget.groupId));
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              group.members!.length.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              group.members!.length == 1 ? "Member" : "Members",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: (group.admin == uid)
                                ? (group.members!.length + 1) * 50
                                : group.members!.length * 50,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoTheme.of(context)
                                .primaryContrastingColor,
                          ),
                          height: (group.admin == uid)
                              ? (group.members!.length + 1) * 50
                              : group.members!.length * 50,
                          child: (group.admin == uid)
                              ? ListView(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    ref.invalidate(
                                                        followerProvider(
                                                            AuthService.uid));
                                                    Navigator.of(context,
                                                            rootNavigator: true)
                                                        .push(
                                                      CupertinoPageRoute(
                                                        builder: (context) =>
                                                            AddMembersGroupPage(
                                                          group: group,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: CupertinoListTile(
                                                    leading: Transform.scale(
                                                      scale: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >
                                                              Constants
                                                                  .limitWidth
                                                          ? 1.3
                                                          : 1,
                                                      child: Icon(
                                                        CupertinoIcons
                                                            .person_add,
                                                        size: 25,
                                                        color:
                                                            CupertinoTheme.of(
                                                                    context)
                                                                .primaryColor,
                                                      ),
                                                    ),
                                                    title: Text(
                                                      "Add Members",
                                                      style: TextStyle(
                                                          color:
                                                              CupertinoTheme.of(
                                                                      context)
                                                                  .primaryColor,
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >
                                                                  Constants
                                                                      .limitWidth
                                                              ? 20
                                                              : 15),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 1,
                                      color: CupertinoColors.opaqueSeparator
                                          .withOpacity(0.2),
                                    ),
                                    memberList(members, group),
                                  ],
                                )
                              : memberList(members, group),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        showLeaveGroupDialog(context);
                      },
                      child: const Text('Leave Group',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemRed,
                          ),
                          textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget memberList(List<AsyncValue<UserData>> members, Group group) {
    return ListView.builder(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: group.members!.length,
        itemBuilder: (context, index) {
          return members[index].when(loading: () {
            return Shimmer.fromColors(
              baseColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
              highlightColor: CupertinoTheme.of(context)
                  .scaffoldBackgroundColor
                  .withOpacity(0.25),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, top: 10.0, bottom: 4.0),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
                            color: CupertinoTheme.of(context)
                                .scaffoldBackgroundColor,
                            height: 32,
                            width: 32,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 15,
                              width: 100,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .scaffoldBackgroundColor
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 10,
                              width: 150,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }, error: (error, stack) {
            return const Text('Error');
          }, data: (userData) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: UserTile(
                        user: userData,
                        isFollowing: null,
                      ),
                    ),
                    if (group.admin == userData.uid)
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text(
                          "Admin",
                          style: TextStyle(
                            color: CupertinoColors.systemGrey4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                (index == group.members!.length - 1)
                    ? const SizedBox()
                    : Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
                      ),
              ],
            );
          });
        });
  }

  void showLeaveGroupDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext newContext) {
        return CupertinoAlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(newContext).pop();
              },
              child: const Text("No"),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.of(newContext).pop();
                BuildContext buildContext = context;
                showCupertinoDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    buildContext = loadingContext;
                    return const CupertinoAlertDialog(
                      content: CupertinoActivityIndicator(),
                    );
                  },
                );

                await _databaseService.toggleGroupJoin(widget.groupId);
                if (!buildContext.mounted) return;
                Navigator.of(buildContext).pop();
                if (widget.canNavigate) {
                  widget.navigateToPage!(const StartMessagingWidget());
                  return;
                }
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
