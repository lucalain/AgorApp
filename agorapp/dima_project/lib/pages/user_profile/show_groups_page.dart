import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/group_tile.dart';
import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowGroupsPage extends ConsumerStatefulWidget {
  final String user;
  const ShowGroupsPage({
    super.key,
    required this.user,
  });

  @override
  ShowGroupsPageState createState() => ShowGroupsPageState();
}

class ShowGroupsPageState extends ConsumerState<ShowGroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final String uid = AuthService.uid;

  @override
  void initState() {
    super.initState();
    ref.read(groupsProvider(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Group>> groups =
        ref.watch(groupsProvider(widget.user));
    final AsyncValue<List<Group>> joinedGroups =
        ref.watch(groupsProvider(AuthService.uid));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: groups.when(
          data: (data) => CupertinoNavigationBarBackButton(
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        middle: Text('Groups',
            style: TextStyle(
              fontSize: 18,
              color: CupertinoTheme.of(context).primaryColor,
            )),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: groups.when(
            data: (groups) {
              return joinedGroups.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (joinedGroups) {
                  int i = 0;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: CupertinoSearchTextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {
                            _searchText = _searchController.text;
                            i = 0;
                          }),
                        ),
                      ),
                      if (groups.isEmpty)
                        Column(
                          children: [
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? MediaQuery.of(context).size.height *
                                            0.6
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: Image.asset(
                                        'assets/darkMode/search_groups.png'))
                                : SizedBox(
                                    height: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? MediaQuery.of(context).size.height *
                                            0.6
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: Image.asset(
                                        'assets/images/search_groups.png')),
                            const Center(
                              child: Text(
                                'No groups',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: CupertinoColors.systemGrey2),
                              ),
                            ),
                          ],
                        )
                      else
                        ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: groups.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final group = groups[index];
                            if (!group.name
                                .toLowerCase()
                                .contains(_searchText.toLowerCase())) {
                              if (i == groups.length - 1) {
                                return Column(
                                  children: [
                                    MediaQuery.of(context).platformBrightness ==
                                            Brightness.dark
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.4,
                                            child: Image.asset(
                                                'assets/darkMode/no_groups_found.png'))
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6
                                                : MediaQuery.of(context).size.height * 0.4,
                                            child: Image.asset('assets/images/no_groups_found.png')),
                                    const Center(
                                      child: Text(
                                        'No groups found',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: CupertinoColors.systemGrey2),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              i++;
                              return const SizedBox.shrink();
                            }
                            return GroupTile(
                              group: group,
                              isJoined:
                                  joinedGroups.any((g) => g.id == group.id)
                                      ? 1
                                      : group.requests!.contains(uid)
                                          ? 2
                                          : 0,
                            );
                          },
                        ),
                    ],
                  );
                },
              );
            },
            loading: () => const CupertinoActivityIndicator(),
            error: (error, stackTrace) {
              return const DeletedAccountWidget();
            },
          ),
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
