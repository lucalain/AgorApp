import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/share_group_tile.dart';
import 'package:dima_project/widgets/share_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareNewsPage extends ConsumerStatefulWidget {
  final DatabaseService databaseService;
  @override
  const ShareNewsPage({
    super.key,
    required this.databaseService,
  });

  @override
  ConsumerState<ShareNewsPage> createState() => ShareNewsPageState();
}

class ShareNewsPageState extends ConsumerState<ShareNewsPage> {
  List<String> uuids = [];
  List<String> groupsIds = [];
  int index = 0;
  List<Group>? groups;
  List<UserData>? users;
  String _searchText = "";
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(groupsProvider(uid));
    ref.read(followerProvider(uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGroups = ref.watch(groupsProvider(uid));
    final asyncUsers = ref.watch(followerProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        middle: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text('Send To',
              style: TextStyle(
                  color: CupertinoTheme.of(context).primaryColor,
                  fontSize: 20)),
        ),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: CupertinoTheme.of(context).primaryColor,
        ),
        trailing: Visibility(
          visible: uuids.isNotEmpty || groupsIds.isNotEmpty,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(10),
            child: const Icon(CupertinoIcons.paperplane),
            onPressed: () {
              dynamic map = {
                "users": uuids,
                "groups": groupsIds,
              };
              Navigator.of(context).pop(map);
            },
          ),
        ),
      ),
      child: SingleChildScrollView(
        reverse: false,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                CustomSelectionOption(
                  textLeft: "Groups",
                  textRight: "Followers",
                  onChanged: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                ),
                if (index == 0) getGroups(asyncGroups),
                if (index == 1) getUsers(asyncUsers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsers(AsyncValue<List<UserData>> asyncUsers) {
    return asyncUsers.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.55
                              : MediaQuery.of(context).size.height * 0.35,
                          child: Image.asset(
                              'assets/darkMode/search_followers.png'))
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.55
                              : MediaQuery.of(context).size.height * 0.35,
                          child: Image.asset(
                              'assets/images/search_followers.png')),
                  const Column(
                    children: [
                      Text(
                        "No followers",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGrey2),
                      ),
                      SizedBox(height: 10),
                      Text("Follow other accounts to share news",
                          style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey2)),
                    ],
                  ),
                ],
              ),
            );
          }
          final filteredUsers = users.where((user) {
            return user.username
                .toLowerCase()
                .contains(_searchText.toLowerCase());
          }).toList();
          if (filteredUsers.isEmpty) {
            return Column(
              children: [
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.55
                            : MediaQuery.of(context).size.height * 0.4,
                        child: Image.asset('assets/darkMode/no_followers.png'))
                    : SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.55
                            : MediaQuery.of(context).size.height * 0.4,
                        child: Image.asset('assets/images/no_followers.png')),
                const Center(
                  child: Text(
                    "No followers found",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey2),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredUsers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ShareUserTile(
                    isLast: index == filteredUsers.length - 1,
                    isFirst: index == 0,
                    user: filteredUsers[index],
                    onSelected: (String uuid) {
                      setState(() {
                        if (uuids.contains(uuid)) {
                          uuids.remove(uuid);
                        } else {
                          uuids.add(uuid);
                        }
                      });
                    },
                    active: uuids.contains(filteredUsers[index].uid!),
                  ),
                  if (index != filteredUsers.length - 1)
                    Container(
                      height: 1,
                      color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
                    ),
                ],
              );
            },
          );
        });
  }

  Widget getGroups(AsyncValue<List<Group>> asyncGroups) {
    return asyncGroups.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child:
                              Image.asset('assets/darkMode/search_groups.png'))
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child:
                              Image.asset('assets/images/search_groups.png')),
                  const Column(
                    children: [
                      Text("No groups",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemGrey2)),
                      SizedBox(height: 10),
                      Text("Join in a group to share news",
                          style: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.systemGrey2)),
                    ],
                  ),
                ],
              ),
            );
          }
          final List<Group> filteredGroups = groups
              .where((group) =>
                  group.name.toLowerCase().contains(_searchText.toLowerCase()))
              .toList();
          if (filteredGroups.isEmpty) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child: Image.asset(
                              'assets/darkMode/no_groups_found.png'))
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child:
                              Image.asset('assets/images/no_groups_found.png')),
                  const Text("No groups found",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.systemGrey2)),
                ],
              ),
            );
          }
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredGroups.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ShareGroupTile(
                    group: filteredGroups[index],
                    onSelected: (String id) {
                      setState(() {
                        if (groupsIds.contains(id)) {
                          groupsIds.remove(id);
                        } else {
                          groupsIds.add(id);
                        }
                      });
                    },
                    active: groupsIds.contains(filteredGroups[index].id),
                    isLast: index == filteredGroups.length - 1,
                    isFirst: index == 0,
                  ),
                  if (index != filteredGroups.length - 1)
                    Container(
                      height: 1,
                      color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
                    ),
                ],
              );
            },
          );
        });
  }
}
