import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/share_group_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareEventsGroupPage extends ConsumerStatefulWidget {
  final List<String> groupIds;
  final DatabaseService databaseService;
  @override
  const ShareEventsGroupPage(
      {super.key, required this.groupIds, required this.databaseService});

  @override
  ConsumerState<ShareEventsGroupPage> createState() =>
      ShareEventGroupPageState();
}

class ShareEventGroupPageState extends ConsumerState<ShareEventsGroupPage> {
  List<String> groupsIds = [];

  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  @override
  void initState() {
    ref.read(groupsProvider(AuthService.uid));
    groupsIds = widget.groupIds;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGroups = ref.watch(groupsProvider(AuthService.uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop(groupsIds);
          },
        ),
        middle: Text(
          "Share with Groups",
          style: TextStyle(
            fontSize: 18,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              top: 16.0,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    placeholder: "Search groups...",
                    onChanged: (_) {
                      setState(() {
                        searchText = _searchController.text;
                      });
                    },
                  ),
                ),
                getGroups(asyncGroups),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getGroups(AsyncValue<List<Group>> asyncGroups) {
    return asyncGroups.when(
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (error, stack) => const Center(child: Text('Error')),
      data: (groups) {
        if (groups.isEmpty) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.6
                            : MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset('assets/darkMode/search_groups.png'))
                    : SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.6
                            : MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset('assets/images/search_groups.png')),
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
            ),
          );
        }
        final List<Group> filteredGroups = groups
            .where((group) =>
                group.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
        if (filteredGroups.isEmpty) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.6
                            : MediaQuery.of(context).size.height * 0.5,
                        child:
                            Image.asset('assets/darkMode/no_groups_found.png'))
                    : SizedBox(
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.height * 0.6
                            : MediaQuery.of(context).size.height * 0.5,
                        child:
                            Image.asset('assets/images/no_groups_found.png')),
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
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredGroups.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final group = filteredGroups[index];
            return Column(
              children: [
                ShareGroupTile(
                  isFirst: index == 0,
                  isLast: index == filteredGroups.length - 1,
                  group: group,
                  onSelected: (String id) {
                    setState(() {
                      if (groupsIds.contains(id)) {
                        groupsIds.remove(id);
                      } else {
                        groupsIds.add(id);
                      }
                    });
                  },
                  active: groupsIds.contains(groups[index].id),
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
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
