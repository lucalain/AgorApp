import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/follow_requests_page.dart';
import 'package:dima_project/pages/options/user_groups_requests_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowRequestPage extends StatefulWidget {
  final DatabaseService databaseService;
  const ShowRequestPage({
    super.key,
    required this.databaseService,
  });
  @override
  ShowRequestPageState createState() => ShowRequestPageState();
}

class ShowRequestPageState extends State<ShowRequestPage> {
  List<UserData> _followRequests = [];
  List<Group> _groupRequests = [];
  final String uid = AuthService.uid;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    List<UserData> followRequests;
    List<Group> groupRequests;
    followRequests = (await widget.databaseService.getFollowRequests(uid));

    followRequests.removeWhere(
        (user) => user.email == "" && user.username == "Deleted Account");
    setState(() {
      _followRequests = followRequests;
    });
    groupRequests = (await widget.databaseService.getUserGroupRequests(uid));
    setState(() {
      _groupRequests = groupRequests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Requests',
            style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.of(context).pop(),
            color: CupertinoTheme.of(context).primaryColor,
          )),
      child: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OptionTile(
                  leading: const Icon(CupertinoIcons.person),
                  onTap: () async => {
                    await Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => FollowRequestsPage(
                                  followRequests: _followRequests,
                                )))
                        .then((value) => init())
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Follow Requests'),
                      _followRequests.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                              child: Text(
                                _followRequests.length.toString(),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.person_2_square_stack),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Group Requests'),
                      _groupRequests.isNotEmpty
                          ? Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                              child: Text(
                                _groupRequests.length.toString(),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                  onTap: () async => {
                    await Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) => UserGroupsRequestsPage(
                                groupRequests: _groupRequests)))
                        .then((value) => init())
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
