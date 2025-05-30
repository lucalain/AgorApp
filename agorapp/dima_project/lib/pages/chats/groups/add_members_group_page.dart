import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/user_invitation_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class AddMembersGroupPage extends ConsumerStatefulWidget {
  final Group group;
  @override
  const AddMembersGroupPage({
    super.key,
    required this.group,
  });

  @override
  AddMembersGroupPageState createState() => AddMembersGroupPageState();
}

class AddMembersGroupPageState extends ConsumerState<AddMembersGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  final String uid = AuthService.uid;
  final List<String> uids = [];
  @override
  void initState() {
    ref.read(followerProvider(uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followerProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  ref.invalidate(groupProvider(widget.group.id));
                  ref.invalidate(userProvider(uid));
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: Text(
          "Add Members",
          style: TextStyle(
            fontSize: 18,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        trailing: Visibility(
          visible: uids.isNotEmpty,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(10),
            child: const Icon(CupertinoIcons.paperplane),
            onPressed: () async {
              BuildContext buildContext = context;
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext newContext) {
                  buildContext = newContext;
                  return const CupertinoAlertDialog(
                    content: CupertinoActivityIndicator(),
                  );
                },
              );
              await databaseService.inviteUserToGroup(
                  widget.group.id, uids, widget.group.members!);
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: "Search followers...",
                onChanged: (_) {
                  setState(() {
                    searchText = _searchController.text;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            asyncUsers.when(
              loading: () => ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor:
                          CupertinoTheme.of(context).primaryContrastingColor,
                      highlightColor: CupertinoTheme.of(context)
                          .primaryContrastingColor
                          .withOpacity(0.5),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: 50,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 8.0),
                                child: Row(
                                  children: [
                                    ClipOval(
                                      child: Container(
                                        color: CupertinoTheme.of(context)
                                            .primaryContrastingColor,
                                        height: 32,
                                        width: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: CupertinoTheme.of(context)
                                                .primaryContrastingColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          height: 15,
                                          width: 100,
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: CupertinoTheme.of(context)
                                                .primaryContrastingColor
                                                .withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                        ],
                      ),
                    );
                  }),
              error: (err, stack) => Text('Error: $err'),
              data: (followers) {
                if (followers.isEmpty) {
                  return SingleChildScrollView(
                    reverse: false,
                    physics: const NeverScrollableScrollPhysics(),
                    child: Center(
                      child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.width >
                                          Constants.limitWidth
                                      ? MediaQuery.of(context).size.width * 0.4
                                      : MediaQuery.of(context).size.width * 0.7,
                                  child: Image.asset(
                                      'assets/darkMode/search_followers.png'))
                              : SizedBox(
                                  height: MediaQuery.of(context).size.width >
                                          Constants.limitWidth
                                      ? MediaQuery.of(context).size.width * 0.4
                                      : MediaQuery.of(context).size.width * 0.7,
                                  child: Image.asset(
                                      'assets/images/search_followers.png')),
                          const Text(
                            'No followers',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemGrey2),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                final filteredUsers = followers.where((user) {
                  return user.username
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase());
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? SizedBox(
                                  height: MediaQuery.of(context).size.width >
                                          Constants.limitWidth
                                      ? MediaQuery.of(context).size.height * 0.5
                                      : MediaQuery.of(context).size.height *
                                          0.4,
                                  child: Image.asset(
                                      'assets/darkMode/no_followers.png'))
                              : SizedBox(
                                  height: MediaQuery.of(context).size.width >
                                          Constants.limitWidth
                                      ? MediaQuery.of(context).size.height * 0.5
                                      : MediaQuery.of(context).size.height *
                                          0.4,
                                  child: Image.asset(
                                      'assets/images/no_followers.png')),
                          MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? const SizedBox(height: 10)
                              : const SizedBox.shrink(),
                          const Text(
                            'No followers found',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemGrey2),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredUsers.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index];

                    return Column(
                      children: [
                        UserInvitationTile(
                          isFirst: index == 0,
                          isLast: index == filteredUsers.length - 1,
                          user: userData,
                          invitePageKey: (String uuid) {
                            setState(() {
                              if (uids.contains(uuid)) {
                                uids.remove(uuid);
                              } else {
                                uids.add(uuid);
                              }
                            });
                          },
                          invited: uids.contains(userData.uid!),
                          isJoining: userData.groups!.contains(widget.group.id),
                        ),
                        if (index != filteredUsers.length - 1)
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
