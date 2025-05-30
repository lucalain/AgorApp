import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowRequestsPage extends ConsumerStatefulWidget {
  final List<UserData> followRequests;
  const FollowRequestsPage({super.key, required this.followRequests});
  @override
  FollowRequestsPageState createState() => FollowRequestsPageState();
}

class FollowRequestsPageState extends ConsumerState<FollowRequestsPage> {
  final String uid = AuthService.uid;
  late List<UserData> followRequests;
  @override
  void initState() {
    followRequests = widget.followRequests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        middle: Text('Follow Requests',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: CupertinoTheme.of(context).primaryColor,
        ),
      ),
      child: (followRequests.isEmpty)
          ? Center(
              child: Column(
                children: [
                  CupertinoTheme.of(context).brightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child: Image.asset(
                            "assets/darkMode/no_follow_requests.png",
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? MediaQuery.of(context).size.height * 0.6
                              : MediaQuery.of(context).size.height * 0.4,
                          child: Image.asset(
                            "assets/images/no_follow_requests.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                  const Text("No follow requests",
                      style: TextStyle(
                          color: CupertinoColors.systemGrey2,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
            )
          : SafeArea(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: followRequests.length,
                itemBuilder: (context, index) {
                  final user = followRequests[index];

                  return Row(
                    children: [
                      Expanded(
                        child: CupertinoListTile(
                          leading: ClipOval(
                            child: Container(
                              width: 100,
                              height: 100,
                              color: CupertinoColors.lightBackgroundGray,
                              child: CreateImageUtils.getUserImage(
                                  user.imagePath!, 1),
                            ),
                          ),
                          title: Text(
                            user.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("${user.name} ${user.surname}"),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          try {
                            await databaseService.acceptUserRequest(
                              user.uid!,
                            );
                            ref.invalidate(followerProvider(uid));
                          } catch (e) {
                            if (!context.mounted) return;
                            showCupertinoDialog(
                                context: context,
                                builder: (context) {
                                  return CupertinoAlertDialog(
                                    title: const Text("Error"),
                                    content:
                                        const Text("User deleted his account"),
                                    actions: [
                                      CupertinoDialogAction(
                                        child: const Text("Ok"),
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                      ),
                                    ],
                                  );
                                });
                          }
                          setState(() {
                            followRequests.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoTheme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: const Text(
                              "Accept",
                              style: TextStyle(color: CupertinoColors.white),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await databaseService.denyUserRequest(
                            user.uid!,
                          );

                          setState(() {
                            followRequests.removeAt(index);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.only(right: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoTheme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: const Text(
                              "Deny",
                              style: TextStyle(color: CupertinoColors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }
}
