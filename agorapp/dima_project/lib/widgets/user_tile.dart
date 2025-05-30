import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/pages/user_profile/user_profile_page.dart';
import 'package:dima_project/pages/user_profile/user_profile_tablet_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserTile extends ConsumerStatefulWidget {
  final UserData user;
  final int? isFollowing; // 0 is not following, 1 is following, 2 is requested
  const UserTile({
    super.key,
    required this.user,
    required this.isFollowing,
  });

  @override
  UserTileState createState() => UserTileState();
}

class UserTileState extends ConsumerState<UserTile> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(userProvider(widget.user.uid!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.invalidate(followerProvider(widget.user.uid!));
              ref.invalidate(followingProvider(widget.user.uid!));
              ref.invalidate(groupsProvider(widget.user.uid!));
              ref.invalidate(joinedEventsProvider(widget.user.uid!));
              ref.invalidate(createdEventsProvider(widget.user.uid!));
              ref.invalidate(userProvider(widget.user.uid!));
              ref.invalidate(followingProvider(uid));

              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return ResponsiveLayout(
                  mobileLayout: UserProfile(
                    user: widget.user.uid!,
                  ),
                  tabletLayout: UserProfileTablet(
                    user: widget.user.uid!,
                  ),
                );
              }));
            },
            child: CupertinoListTile(
              leading: Transform.scale(
                scale: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 1.3
                    : 1,
                child: ClipOval(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: CupertinoColors.lightBackgroundGray,
                    child: CreateImageUtils.getUserImage(
                        widget.user.imagePath!, 1),
                  ),
                ),
              ),
              title: Text(
                widget.user.username,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 20
                            : 17),
              ),
              subtitle: Text("${widget.user.name} ${widget.user.surname}",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? 15
                          : 12)),
            ),
          ),
        ),
        widget.user.uid != uid && widget.isFollowing != null
            ? GestureDetector(
                onTap: () async {
                  try {
                    await databaseService.toggleFollowUnfollow(
                      widget.user.uid!,
                      uid,
                    );
                    ref.invalidate(followingProvider(uid));
                    ref.invalidate(followerProvider(widget.user.uid!));
                    ref.invalidate(followerProvider(uid));
                    ref.invalidate(userProvider(widget.user.uid!));
                    ref.invalidate(userProvider(uid));
                  } catch (e) {
                    if (!context.mounted) return;
                    final String state = widget.isFollowing == 0
                        ? "follow"
                        : widget.isFollowing == 1
                            ? "unfollow"
                            : "cancel request to";
                    showCupertinoDialog(
                        context: context,
                        builder: (newContext) {
                          return CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: Text('Failed to $state the user'),
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
                child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      widget.isFollowing == 0
                          ? "Follow"
                          : widget.isFollowing == 1
                              ? "Unfollow"
                              : "Requested",
                      style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? 18
                              : 15),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
