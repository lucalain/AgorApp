import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowFollowingPage extends ConsumerStatefulWidget {
  final String user;
  const ShowFollowingPage({
    super.key,
    required this.user,
  });

  @override
  ShowFollowingPageState createState() => ShowFollowingPageState();
}

class ShowFollowingPageState extends ConsumerState<ShowFollowingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final String uid = AuthService.uid;

  @override
  void initState() {
    ref.read(followingProvider(widget.user));
    ref.read(followingProvider(uid));
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followingProvider(widget.user));
    final AsyncValue<List<UserData>> asyncFollowing =
        ref.watch(followingProvider(uid));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: asyncUsers.when(
          data: (data) => CupertinoNavigationBarBackButton(
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        middle: Text(
          'Following',
          style: TextStyle(
            fontSize: 18,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: SafeArea(
          child: asyncUsers.when(
            loading: () => const CupertinoActivityIndicator(),
            error: (err, stack) => const DeletedAccountWidget(),
            data: (users) {
              int i = 0;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      onChanged: (_) {
                        setState(() {
                          _searchText = _searchController.text;
                          i = 0;
                        });
                      },
                    ),
                  ),
                  if (users.isEmpty)
                    Column(
                      children: [
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? SizedBox(
                                height: MediaQuery.of(context).size.width >
                                        Constants.limitWidth
                                    ? MediaQuery.of(context).size.height * 0.6
                                    : MediaQuery.of(context).size.height * 0.4,
                                child: Image.asset(
                                    'assets/darkMode/no_following.png'))
                            : SizedBox(
                                height: MediaQuery.of(context).size.width >
                                        Constants.limitWidth
                                    ? MediaQuery.of(context).size.height * 0.6
                                    : MediaQuery.of(context).size.height * 0.4,
                                child: Image.asset(
                                    'assets/images/no_following.png')),
                        const Text(
                          'No following anyone',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemGrey2),
                        ),
                      ],
                    )
                  else
                    ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: users.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        if (!user.username
                            .toLowerCase()
                            .contains(_searchText.toLowerCase())) {
                          if (i == users.length - 1) {
                            return Column(
                              children: [
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
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
                                            'assets/darkMode/search_following.png'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width >
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
                                            'assets/images/search_following.png'),
                                      ),
                                const Center(
                                  child: Text(
                                    'No following found',
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

                        return asyncFollowing.when(
                          loading: () => const CupertinoActivityIndicator(),
                          error: (err, stack) => Text('Error: $err'),
                          data: (following) {
                            return UserTile(
                              user: user,
                              isFollowing:
                                  following.any((u) => u.uid == user.uid)
                                      ? 1
                                      : user.isPublic == false &&
                                              user.requests!.contains(uid)
                                          ? 2
                                          : 0,
                            );
                          },
                        );
                      },
                    ),
                ],
              );
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
