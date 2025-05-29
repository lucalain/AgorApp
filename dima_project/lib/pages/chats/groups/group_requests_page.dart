import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class GroupRequestsPage extends ConsumerStatefulWidget {
  final String groupId;
  final List<UserData> requests;
  final bool canNavigate;
  final Function? navigateToPage;
  final DatabaseService databaseService;
  final NotificationService notificationService;

  const GroupRequestsPage({
    super.key,
    required this.groupId,
    required this.requests,
    required this.canNavigate,
    this.navigateToPage,
    required this.databaseService,
    required this.notificationService,
  });

  @override
  GroupRequestsPageState createState() => GroupRequestsPageState();
}

class GroupRequestsPageState extends ConsumerState<GroupRequestsPage> {
  late List<UserData> users;
  late final DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = widget.databaseService;
    users = widget.requests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () async {
            ref.invalidate(groupProvider(widget.groupId));
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupInfoPage(
                groupId: widget.groupId,
                canNavigate: widget.canNavigate,
                navigateToPage: widget.navigateToPage,
                databaseService: _databaseService,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
              ));
              return;
            }
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        ),
        middle: Text(
          'Group Requests',
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: users.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Column(
                  mainAxisAlignment:
                      MediaQuery.of(context).size.width > Constants.limitWidth
                          ? MainAxisAlignment.center
                          : MainAxisAlignment.start,
                  children: [
                    CupertinoTheme.of(context).brightness == Brightness.dark
                        ? SizedBox(
                            height: MediaQuery.of(context).size.width >
                                    Constants.limitWidth
                                ? MediaQuery.of(context).size.height * 0.7
                                : MediaQuery.of(context).size.height * 0.4,
                            child: Image.asset(
                              "assets/darkMode/no_group_requests.png",
                              fit: BoxFit.cover,
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.width >
                                    Constants.limitWidth
                                ? MediaQuery.of(context).size.height * 0.7
                                : MediaQuery.of(context).size.height * 0.4,
                            child: Image.asset(
                              "assets/images/no_group_requests.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                    const Text("No group requests",
                        style: TextStyle(
                            color: CupertinoColors.systemGrey2,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final UserData user = users[index];
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
                          await _databaseService.acceptGroupRequest(
                              widget.groupId, user.uid!);
                        } catch (error) {
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
                          users.removeAt(index);
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
                        await _databaseService.denyGroupRequest(
                            widget.groupId, user.uid!);
                        setState(() {
                          users.removeAt(index);
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
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
