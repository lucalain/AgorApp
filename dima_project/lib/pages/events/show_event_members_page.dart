import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowEventMembersPage extends ConsumerStatefulWidget {
  final String eventId;
  final String detailId;
  final String admin;
  const ShowEventMembersPage({
    super.key,
    required this.eventId,
    required this.detailId,
    required this.admin,
  });

  @override
  ShowEventMembersPageState createState() => ShowEventMembersPageState();
}

class ShowEventMembersPageState extends ConsumerState<ShowEventMembersPage> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(followingProvider(uid));
    ref.read(eventProvider(widget.eventId));
    ref.read(userProvider(uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.eventId));
    final followings = ref.watch(followingProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Text('Participants',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
      ),
      child: event.when(
        data: (event) {
          final detail = event.details!.firstWhere(
            (element) => element.id == widget.detailId,
            orElse: () => throw Exception('Detail not found'),
          );
          return ListView.builder(
            itemCount: detail.members!.length,
            itemBuilder: (context, index) {
              final user = ref.watch(userProvider(detail.members![index]));

              return user.when(
                data: (userData) {
                  return followings.when(
                      data: (data) {
                        final isFollowing =
                            data.any((element) => element.uid! == userData.uid)
                                ? 1
                                : userData.requests!.contains(uid)
                                    ? 2
                                    : 0;
                        if (userData.uid == widget.admin) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: UserTile(
                                  user: userData,
                                  isFollowing: isFollowing,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 20.0),
                                child: Text(
                                  "Host",
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return Row(children: [
                          Expanded(
                            child: UserTile(
                              user: userData,
                              isFollowing: isFollowing,
                            ),
                          ),
                          const SizedBox(width: 53),
                        ]);
                      },
                      loading: () => const CupertinoActivityIndicator(),
                      error: (error, stack) => Text('Error: $error'));
                },
                loading: () => const CupertinoActivityIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          );
        },
        loading: () => const CupertinoActivityIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
