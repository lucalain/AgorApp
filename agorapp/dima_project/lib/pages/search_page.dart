import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/events/event_tile.dart';
import 'package:dima_project/widgets/group_tile.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerStatefulWidget {
  final DatabaseService databaseService;
  const SearchPage({
    super.key,
    required this.databaseService,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<QueryDocumentSnapshot<Object?>>>
      _searchStreamController =
      StreamController<List<QueryDocumentSnapshot<Object?>>>();

  StreamSubscription<List<QueryDocumentSnapshot<Object?>>>?
      _searchStreamSubscription;

  int searchIdx = 0;
  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
  }

  void _initiateSearchMethod() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      _searchStreamSubscription?.cancel();

      if (searchIdx == 0) {
        _searchStreamSubscription = widget.databaseService
            .searchByUsernameStream(searchText)
            .listen((snapshot) {
          _searchStreamController.add(snapshot);
        });
      } else if (searchIdx == 1) {
        _searchStreamSubscription = widget.databaseService
            .searchByGroupNameStream(searchText)
            .listen((snapshot) {
          _searchStreamController.add(snapshot);
        });
      } else {
        _searchStreamSubscription = widget.databaseService
            .searchByEventNameStream(searchText)
            .listen((snapshot) {
          _searchStreamController.add(snapshot);
        });
      }
    } else {
      _searchStreamController.add([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final followings = ref.watch(followingsStreamProvider(uid));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        middle: Text(
          "Search",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10),
            child: CupertinoSearchTextField(
              controller: _searchController,
              onChanged: (_) => _initiateSearchMethod(),
              placeholder:
                  "Search${searchIdx == 0 ? " users" : searchIdx == 1 ? " groups" : " events"}...",
            ),
          ),
          CustomSelectionOption(
            textLeft: "Users",
            textRight: "Events",
            textMiddle: "Groups",
            onChanged: (value) {
              setState(() {
                searchIdx = value;
                _initiateSearchMethod();
              });
            },
          ),
          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot<Object?>>>(
              stream: _searchStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  if (_searchController.text.isNotEmpty) {
                    return SingleChildScrollView(
                      reverse: false,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Center(
                        child: Column(
                          children: [
                            searchIdx == 0
                                ? MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                        child: Image.asset(
                                            'assets/darkMode/no_users_found.png'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                        child: Image.asset(
                                            'assets/images/no_users_found.png'),
                                      )
                                : searchIdx == 1
                                    ? MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/darkMode/no_groups_found.png'),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/images/no_groups_found.png'),
                                          )
                                    : MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/darkMode/no_events_found.png'),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/images/no_events_found.png'),
                                          ),
                            Text(
                                "No ${searchIdx == 0 ? "users" : searchIdx == 1 ? "groups" : "events"} found",
                                style: const TextStyle(
                                  color: CupertinoColors.inactiveGray,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 5),
                            Text(
                              searchIdx == 0
                                  ? "There is no account with this username"
                                  : searchIdx == 1
                                      ? "There is no group with this name"
                                      : "There is no event with this name",
                              style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Stack(children: [
                    Positioned(
                      top: 0,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      left: 0,
                      right: 0,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        reverse: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            searchIdx == 0
                                ? MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                        child: Image.asset(
                                            'assets/darkMode/search_users.png'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                        child: Image.asset(
                                            'assets/images/search_users.png'),
                                      )
                                : searchIdx == 1
                                    ? MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/darkMode/search_groups.png'),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/images/search_groups.png'),
                                          )
                                    : MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.dark
                                        ? SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/darkMode/search_events.png'),
                                          )
                                        : SizedBox(
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.45
                                                : MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                            child: Image.asset(
                                                'assets/images/search_events.png'),
                                          ),
                            Text(
                                "Search for ${searchIdx == 0 ? "users" : searchIdx == 1 ? "groups" : "events"}",
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 5),
                            Text(
                              searchIdx == 0
                                  ? "Digit to find users"
                                  : searchIdx == 1
                                      ? "Digit to find groups"
                                      : "Digit to find events",
                              style: const TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]);
                }
                final data =
                    docs as List<QueryDocumentSnapshot<Map<String, dynamic>>>;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    if (searchIdx == 0 &&
                        (data[index].data()).containsKey('email')) {
                      final userData = UserData.fromSnapshot(docs[index]);
                      return followings.when(
                          data: (followingData) {
                            final int isFollowing = followingData
                                    .any((element) => element == userData.uid)
                                ? 1
                                : userData.requests!.contains(uid)
                                    ? 2
                                    : 0;
                            return UserTile(
                              user: userData,
                              isFollowing: isFollowing,
                            );
                          },
                          loading: () => const CupertinoActivityIndicator(),
                          error: (error, stackTrace) {
                            return Text('Error: $error');
                          });
                    } else if (searchIdx == 1 &&
                        (data[index].data()).containsKey('groupId')) {
                      final group = Group.fromSnapshot(docs[index]);

                      return GroupTile(
                        group: group,
                        isJoined: group.members!.contains(uid)
                            ? 1
                            : group.requests!.contains(uid)
                                ? 2
                                : 0,
                      );
                    } else if (searchIdx == 2 &&
                        (data[index].data()).containsKey('eventId')) {
                      return FutureBuilder(
                          future: Event.fromSnapshot(docs[index]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              if (snapshot.data == null ||
                                  snapshot.data is! Event) {
                                return const SizedBox.shrink();
                              }
                              final event = snapshot.data as Event;
                              return EventTile(
                                event: event,
                              );
                            }
                          });
                    } else {
                      return Container();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchStreamController.close(); // Close the stream controller
    _searchStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}
