import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/show_event.dart';
import 'package:dima_project/pages/events/show_event_tablet.dart';
import 'package:dima_project/pages/options/options_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/events/event_grid.dart';
import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:dima_project/pages/user_profile/show_followers_page.dart';
import 'package:dima_project/pages/user_profile/show_following_page.dart';
import 'package:dima_project/pages/user_profile/show_groups_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UserProfileTablet extends ConsumerStatefulWidget {
  final String user;
  @override
  const UserProfileTablet({
    super.key,
    required this.user,
  });

  @override
  UserProfileTabletState createState() => UserProfileTabletState();
}

class UserProfileTabletState extends ConsumerState<UserProfileTablet> {
  late final bool isMyProfile;

  int index = 0;
  bool navigatorCanPop = false;
  final String uid = AuthService.uid;
  late final NotificationService notificationService;

  @override
  void initState() {
    super.initState();
    isMyProfile = uid == widget.user;
    ref.read(userProvider(widget.user));
    ref.read(followerProvider(widget.user));
    ref.read(followingProvider(widget.user));
    ref.read(followingProvider(uid));
    ref.read(groupsProvider(widget.user));
    ref.read(joinedEventsProvider(widget.user));
    ref.read(createdEventsProvider(widget.user));
    notificationService = ref.read(notificationServiceProvider);

    setState(() {
      navigatorCanPop = canNavigatorPop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider(widget.user));

    return user.when(
      data: (user) {
        if (user.username == 'Deleted Account' && user.email == '') {
          return const DeletedAccountWidget();
        }
        return _buildProfile(user);
      },
      loading: () => const CupertinoActivityIndicator(),
      error: (error, stackTrace) {
        return const Center(
          child: Text('Error:'),
        );
      },
    );
  }

  bool canNavigatorPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  Widget _buildProfile(UserData user) {
    final databaseService = ref.read(databaseServiceProvider);
    final followings = ref.watch(followingProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: (navigatorCanPop)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    fontSize: 25,
                  ),
                ),
              ),
        middle: navigatorCanPop
            ? Text(
                user.username,
                style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  fontSize: 20,
                ),
              )
            : null,
        trailing: isMyProfile
            ? GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => OptionsPage(
                              authService: AuthService(),
                              notificationService: notificationService,
                            ))),
                child: Icon(CupertinoIcons.bars,
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              )
            : null,
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CreateImageUtils.getUserImage(user.imagePath!, 2),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10),
                  child: Text(
                    '${user.name} ${user.surname}',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getGroups(),
                    const SizedBox(width: 40),
                    getFollowers(),
                    const SizedBox(width: 40),
                    getFollowings(),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0.0,
                        mainAxisSpacing: 0.0,
                        childAspectRatio: 0.2,
                      ),
                      itemCount: user.categories.length,
                      itemBuilder: (context, index) {
                        final category = user.categories[index];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CategoryUtil.iconForCategory(category),
                              size: 18,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                !isMyProfile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 8),
                            onPressed: () async {
                              try {
                                await databaseService.toggleFollowUnfollow(
                                    widget.user, uid);
                                ref.invalidate(followingProvider(uid));
                                ref.invalidate(followerProvider(widget.user));
                                ref.invalidate(userProvider(widget.user));
                              } catch (e) {
                                if (!mounted) return;

                                showCupertinoDialog(
                                    context: context,
                                    builder: (newContext) {
                                      return CupertinoAlertDialog(
                                        title: const Text('Error'),
                                        content: const Text(
                                            'User deleted his/her account'),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            child: const Text('OK'),
                                            onPressed: () {
                                              ref.invalidate(followingProvider);
                                              ref.invalidate(followerProvider);
                                              ref.invalidate(userProvider);
                                              Navigator.of(newContext).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                            child: followings.when(
                              data: (followings) {
                                return Text(
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                    followings.any((element) =>
                                            element.uid! == widget.user)
                                        ? "Unfollow"
                                        : user.requests!.contains(uid)
                                            ? "Requested"
                                            : "Follow");
                              },
                              loading: () => const CupertinoActivityIndicator(),
                              error: (error, stackTrace) {
                                return const Center(
                                  child: Text('N.A.'),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            onPressed: () async {
                              var members = [uid, widget.user];
                              members.sort();
                              final chat = PrivateChat(
                                members: members,
                              );
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                    builder: (context) => PrivateChatPage(
                                      storageService: StorageService(),
                                      privateChat: chat,
                                      canNavigate: false,
                                      user: user,
                                      notificationService: notificationService,
                                      databaseService: databaseService,
                                      imagePicker: ImagePicker(),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Icon(
                              FontAwesomeIcons.envelope,
                              color: CupertinoColors.white,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: followings.when(
              data: (followings) {
                return (isMyProfile ||
                        user.isPublic! ||
                        followings
                            .any((element) => element.uid! == widget.user))
                    ? Column(
                        children: [
                          CustomSelectionOption(
                            textLeft: 'Events created',
                            textRight: 'Events joined',
                            onChanged: (value) {
                              setState(() {
                                index = value;
                              });
                            },
                          ),
                          getCreatedEvents(user),
                          getJoinedEvents(user),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          children: [
                            Icon(
                              LineAwesomeIcons.user_lock_solid,
                              size: 100,
                              color: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "This Account is private",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                              ),
                            ),
                            Text(
                              "Follow this account to see its events",
                              style: TextStyle(
                                fontSize: 15,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                              ),
                            ),
                          ],
                        ),
                      );
              },
              loading: () => const CupertinoActivityIndicator(),
              error: (error, stackTrace) {
                return const Center(
                  child: Text('N.A.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget getJoinedEvents(UserData user) {
    final events = ref.watch(joinedEventsProvider(widget.user));

    return Visibility(
      visible: index == 1,
      child: events.when(
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CupertinoColors.systemGrey, width: 2),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.calendar_times,
                          color: CupertinoColors.systemGrey,
                          size: 50,
                        )),
                    const SizedBox(height: 10),
                    const Text(
                      'No events yet',
                      style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ResponsiveLayout(
                              tabletLayout: ShowEventTablet(
                                eventId: event.id!,
                                userData: user,
                                createdEvents: false,
                              ),
                              mobileLayout: ShowEvent(
                                eventId: event.id!,
                                userData: user,
                                createdEvents: false,
                              ),
                            ),
                          ),
                        ),
                        child: EventGrid(
                          event: event,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
          error: (error, stackTrace) {
            return const Center(
              child: Text('N.A.'),
            );
          },
          loading: () => const CupertinoActivityIndicator()),
    );
  }

  Widget getCreatedEvents(UserData user) {
    final events = ref.watch(createdEventsProvider(widget.user));

    return Visibility(
      visible: index == 0,
      child: events.when(
          data: (events) {
            if (events.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: CupertinoColors.systemGrey, width: 2),
                        ),
                        child: const Icon(
                          LineAwesomeIcons.calendar_times,
                          color: CupertinoColors.systemGrey,
                          size: 50,
                        )),
                    const SizedBox(height: 10),
                    const Text(
                      'No events yet',
                      style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            } else {
              return Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 5.0,
                      mainAxisSpacing: 5.0,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ResponsiveLayout(
                              tabletLayout: ShowEventTablet(
                                eventId: event.id!,
                                userData: user,
                                createdEvents: true,
                              ),
                              mobileLayout: ShowEvent(
                                eventId: event.id!,
                                userData: user,
                                createdEvents: true,
                              ),
                            ),
                          ),
                        ),
                        child: EventGrid(
                          event: event,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
          error: (error, stackTrace) {
            return const Center(
              child: Text('N.A.'),
            );
          },
          loading: () => const CupertinoActivityIndicator()),
    );
  }

  Widget getGroups() {
    final groups = ref.watch(groupsProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(groupsProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ShowGroupsPage(
                  user: widget.user,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 60,
            child: Column(
              children: [
                groups.when(
                  data: (groups) {
                    return Text(
                      groups.length.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                      ),
                    );
                  },
                  loading: () => Text(
                    '',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                  error: (error, stackTrace) {
                    return const Center(
                      child: Text('N.A.'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text("Groups",
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getFollowers() {
    final followers = ref.watch(followerProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(followerProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ShowFollowersPage(
                  user: widget.user,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 60,
            child: Column(
              children: [
                followers.when(
                  data: (followers) {
                    return Text(
                      followers.length.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                      ),
                    );
                  },
                  loading: () => Text(
                    '',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                  error: (error, stackTrace) {
                    return const Center(
                      child: Text('N.A.'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Followers",
                  style: TextStyle(
                    fontSize: 18,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget getFollowings() {
    final following = ref.watch(followingProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(followingProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ShowFollowingPage(
                  user: widget.user,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 60,
            child: Column(
              children: [
                following.when(
                  data: (following) {
                    return Text(
                      following.length.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                      ),
                    );
                  },
                  loading: () => Text(
                    '',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                  ),
                  error: (error, stackTrace) {
                    return const Center(
                      child: Text('N.A.'),
                    );
                  },
                ),
                const SizedBox(height: 10),
                Text(
                  "Following",
                  style: TextStyle(
                    fontSize: 18,
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
