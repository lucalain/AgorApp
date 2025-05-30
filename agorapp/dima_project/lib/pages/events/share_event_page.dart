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

class ShareEventPage extends ConsumerStatefulWidget {
  final DatabaseService databaseService;
  final String eventId;
  @override
  const ShareEventPage({
    super.key,
    required this.databaseService,
    required this.eventId,
  });

  @override
  ConsumerState<ShareEventPage> createState() => ShareEventPageState();
}

class ShareEventPageState extends ConsumerState<ShareEventPage> {
  List<String> uuids = [];
  List<String> groupsIds = [];
  int index = 0;
  String _searchText = "";
  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncFollowers = ref.watch(followerProvider(AuthService.uid));
    final asyncGroups = ref.watch(groupsProvider(AuthService.uid));
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
              await widget.databaseService
                  .sendEventsToGroups(widget.eventId, groupsIds);
              await widget.databaseService
                  .sendEventsToPrivateChats(widget.eventId, uuids);
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
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
                if (index == 1) getUsers(asyncFollowers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsers(AsyncValue<List<UserData>> asyncFollowers) {
    return asyncFollowers.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
        data: (users) {
          if (users.isEmpty) {
            return Column(
              children: [
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                        child:
                            Image.asset('assets/darkMode/search_followers.png'))
                    : SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.width * 0.4
                            : MediaQuery.of(context).size.width * 0.7,
                        child:
                            Image.asset('assets/images/search_followers.png')),
                const Center(
                  child: Text(
                    "No followers",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey2),
                  ),
                ),
              ],
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
            physics: const ClampingScrollPhysics(),
            itemCount: filteredUsers.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ShareUserTile(
                    isFirst: index == 0,
                    isLast: index == filteredUsers.length - 1,
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
        error: (error, stack) => const Center(child: Text('Error')),
        loading: () => const Center(child: CupertinoActivityIndicator()),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.55
                              : MediaQuery.of(context).size.height * 0.4,
                          child:
                              Image.asset('assets/darkMode/search_groups.png'))
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.55
                              : MediaQuery.of(context).size.height * 0.4,
                          child:
                              Image.asset('assets/images/search_groups.png')),
                  const Text(
                    "No groups",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemGrey2),
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
                            'assets/darkMode/no_groups_found.png',
                            fit: BoxFit.fill,
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child: Image.asset(
                            'assets/images/no_groups_found.png',
                            fit: BoxFit.fill,
                          )),
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
            physics: const ClampingScrollPhysics(),
            itemCount: filteredGroups.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  ShareGroupTile(
                    isFirst: index == 0,
                    isLast: index == filteredGroups.length - 1,
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
