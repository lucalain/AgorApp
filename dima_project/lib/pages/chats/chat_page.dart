import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/create_group_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/chats/group_chat_tile.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/chats/private_chat_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class ChatPage extends StatefulWidget {
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  final StorageService storageService;
  const ChatPage({
    super.key,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
    required this.storageService,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final Stream<List<PrivateChat>> _privateChatsStream;
  late final Stream<List<Group>> _groupsStream;
  final String uid = AuthService.uid;
  String searchedText = "";
  int idx = 0;
  late final DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _databaseService = widget.databaseService;
    _privateChatsStream = _databaseService.getPrivateChatsStream();
    _groupsStream = _databaseService.getGroupsStream();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        trailing: idx == 0
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => CreateGroupPage(
                                canNavigate: false,
                                imagePicker: widget.imagePicker,
                              )));
                },
                child: const Icon(
                  CupertinoIcons.add_circled_solid,
                  size: 30,
                ),
              )
            : null,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          "Chats",
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                setState(() {
                  searchedText = value;
                });
              },
            ),
          ),
          CustomSelectionOption(
            textLeft: "Groups",
            textRight: "Private",
            onChanged: (value) {
              setState(() {
                idx = value;
              });
            },
          ),
          Expanded(
            child: Stack(
              children: [
                groupList(),
                privateChatList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget groupList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Group>>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          if (idx == 1) {
            return const SizedBox.shrink();
          }
          int i = 0;
          if (snapshot.hasData) {
            var data = snapshot.data!;
            if (data.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final group = data[index];
                  if (!group.name
                      .toLowerCase()
                      .contains(searchedText.toLowerCase())) {
                    i += 1;
                    if (i == data.length) {
                      return Center(
                          child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Image.asset(
                                      'assets/darkMode/no_groups_chat_found.png'),
                                )
                              : SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.5,
                                  child: Image.asset(
                                      'assets/images/no_groups_chat_found.png'),
                                ),
                          const Text(
                            'No groups found',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemGrey2),
                          ),
                        ],
                      ));
                    }
                    return const SizedBox.shrink();
                  }
                  if (group.lastMessage == null) {
                    return GroupChatTile(
                      storageService: widget.storageService,
                      username: '',
                      group: group,
                      databaseService: _databaseService,
                      notificationService: widget.notificationService,
                      imagePicker: widget.imagePicker,
                    );
                  }
                  return StreamBuilder(
                      stream: _databaseService.getUserDataFromUID(
                          group.lastMessage!.recentMessageSender),
                      builder: (context, snapshot) {
                        String username = "";
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          username = "";
                        }
                        if (snapshot.hasError) {
                          username = "Deleted Account";
                        }
                        if (snapshot.hasData) {
                          username =
                              UserData.fromSnapshot(snapshot.data!).username;
                        }
                        return GroupChatTile(
                          storageService: widget.storageService,
                          group: group,
                          username: username,
                          databaseService: _databaseService,
                          notificationService: widget.notificationService,
                          imagePicker: widget.imagePicker,
                        );
                      });
                },
              );
            } else {
              return noChatWidget();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor:
                        CupertinoTheme.of(context).primaryContrastingColor,
                    highlightColor: CupertinoTheme.of(context)
                        .primaryContrastingColor
                        .withOpacity(0.5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
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
                                padding: const EdgeInsets.all(8.0),
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget noChatWidget() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            idx == 0
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset(
                          'assets/darkMode/search_groups_chat.png',
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset(
                          'assets/images/search_groups_chat.png',
                        ),
                      )
                : MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset(
                          'assets/darkMode/search_chat.png',
                        ),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Image.asset(
                          'assets/images/search_chat.png',
                        ),
                      ),
            Text(
              "No ${idx == 0 ? "groups" : "chats"} yet",
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              idx == 0
                  ? "Create a group to start chatting"
                  : "Create a chat to start chatting",
              style: const TextStyle(
                  color: CupertinoColors.systemGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget privateChatList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: StreamBuilder<List<PrivateChat>>(
        stream: _privateChatsStream,
        builder: (context, snapshot) {
          if (idx == 0) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData) {
            bool found = false;

            var data = snapshot.data!;

            if (data.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final privateChat = data[index];

                  if (privateChat.lastMessage == null) {
                    return const SizedBox();
                  }

                  return StreamBuilder(
                    stream: _databaseService.getUserDataFromUID(
                        privateChat.members[0] == uid
                            ? privateChat.members[1]
                            : privateChat.members[0]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final other = UserData.fromSnapshot(snapshot.data!);

                        if (!other.username
                            .toLowerCase()
                            .contains(searchedText.toLowerCase())) {
                          if (index == data.length - 1 && !found) {
                            return Center(
                                child: Column(
                              children: [
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Image.asset(
                                            'assets/darkMode/no_chat_found.png'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Image.asset(
                                            'assets/images/no_chat_found.png'),
                                      ),
                                const Text(
                                  'No private chats found',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.systemGrey2),
                                ),
                              ],
                            ));
                          }
                          return const SizedBox.shrink();
                        }
                        found = true;
                        return PrivateChatTile(
                          storageService: widget.storageService,
                          privateChat: privateChat,
                          other: other,
                          databaseService: _databaseService,
                          notificationService: widget.notificationService,
                          imagePicker: widget.imagePicker,
                        );
                      } else {
                        if (snapshot.hasError) {
                          if (!("Deleted Account")
                              .toLowerCase()
                              .contains(searchedText.toLowerCase())) {
                            if (index == data.length - 1 && !found) {
                              return Center(
                                  child: Column(
                                children: [
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          child: Image.asset(
                                              'assets/darkMode/no_chat_found.png'),
                                        )
                                      : SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.5,
                                          child: Image.asset(
                                              'assets/images/no_chat_found.png'),
                                        ),
                                  const Text(
                                    'No private chats found',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoColors.systemGrey2),
                                  ),
                                ],
                              ));
                            }
                            return const SizedBox.shrink();
                          }
                          return PrivateChatTile(
                            storageService: widget.storageService,
                            privateChat: privateChat,
                            other: UserData(
                              imagePath: '',
                              username: 'Deleted Account',
                              categories: [],
                              email: '',
                              name: '',
                              surname: '',
                            ),
                            databaseService: _databaseService,
                            notificationService: widget.notificationService,
                            imagePicker: widget.imagePicker,
                          );
                        }
                        return Container();
                      }
                    },
                  );
                },
              );
            } else {
              return noChatWidget();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor:
                        CupertinoTheme.of(context).primaryContrastingColor,
                    highlightColor: CupertinoTheme.of(context)
                        .primaryContrastingColor
                        .withOpacity(0.5),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
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
                                padding: const EdgeInsets.all(8.0),
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
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
