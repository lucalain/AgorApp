import 'package:dima_project/pages/options/delete_account_page.dart';
import 'package:dima_project/pages/options/request_page.dart';
import 'package:dima_project/pages/options/settings_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OptionsPage extends ConsumerStatefulWidget {
  final AuthService authService;
  final NotificationService notificationService;
  const OptionsPage({
    super.key,
    required this.authService,
    required this.notificationService,
  });
  @override
  OptionsPageState createState() => OptionsPageState();
}

class OptionsPageState extends ConsumerState<OptionsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Options',
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor, fontSize: 18),
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
                  leading: const Icon(CupertinoIcons.square_list),
                  onTap: () => {
                    Navigator.of(context, rootNavigator: true).push(
                        CupertinoPageRoute(
                            builder: (context) => ShowRequestPage(
                                databaseService: databaseService)))
                  },
                  title: const Text('Request'),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.of(context, rootNavigator: true)
                      .push(CupertinoPageRoute(
                          builder: (context) => SettingsPage(
                                notificationService: widget.notificationService,
                              ))),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.trash),
                  title: const Text('Delete Account'),
                  onTap: () async => await deleteAccount(databaseService),
                ),
                OptionTile(
                  leading: const Icon(CupertinoIcons.arrow_right_to_line),
                  title: const Text('Exit'),
                  onTap: () async {
                    await _signOut(context, databaseService);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(
      BuildContext context, DatabaseService databaseService) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await databaseService.updateToken('');
    await widget.notificationService.unsubscribeAndClearTopics();
    await widget.authService.signOut();
    ref.invalidate(userProvider);
    ref.invalidate(followerProvider);
    ref.invalidate(followingProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(joinedEventsProvider);
    ref.invalidate(createdEventsProvider);
    ref.invalidate(eventProvider);
    ref.invalidate(notifyGroupProvider);
    ref.invalidate(notifyPrivateChatProvider);
    ref.invalidate(newsPrivateChatProvider);
    ref.invalidate(eventsPrivateChatProvider);
    ref.invalidate(imagesPrivateChatProvider);
    ref.invalidate(imagesGroupProvider);
    ref.invalidate(newsGroupProvider);
    ref.invalidate(eventsGroupProvider);
    ref.invalidate(requestsGroupProvider);
    if (!context.mounted) return;
    context.go('/login');
  }

  Future<void> deleteAccount(DatabaseService databaseService) async {
    final bool isSignedInWithGoogle =
        (await databaseService.getUserData(AuthService.uid))
            .isSignedInWithGoogle!;
    if (!mounted) return;
    if (isSignedInWithGoogle) {
      BuildContext buildContext = context;

      showCupertinoDialog(
        context: context,
        builder: (BuildContext newContext) {
          return CupertinoAlertDialog(
            title: const Text('Delete Account'),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: <CupertinoDialogAction>[
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(newContext).pop();
                },
              ),
              CupertinoDialogAction(
                  child: const Text('Yes'),
                  onPressed: () async {
                    Navigator.of(newContext).pop();
                    showCupertinoDialog(
                      context: context,
                      builder: (BuildContext loadingContext) {
                        buildContext = loadingContext;
                        return const CupertinoAlertDialog(
                          content: CupertinoActivityIndicator(),
                        );
                      },
                    );
                    final bool isReauthenticated =
                        await widget.authService.reauthenticateUserWithGoogle();

                    if (isReauthenticated) {
                      await databaseService.updateToken('');
                      await databaseService.deleteUser();
                      await widget.notificationService
                          .unsubscribeAndClearTopics();
                      ref.invalidate(userProvider);
                      ref.invalidate(followerProvider);
                      ref.invalidate(followingProvider);
                      ref.invalidate(groupsProvider);
                      ref.invalidate(joinedEventsProvider);
                      ref.invalidate(createdEventsProvider);
                      ref.invalidate(eventProvider);

                      ref.invalidate(notifyGroupProvider);
                      ref.invalidate(notifyPrivateChatProvider);
                      ref.invalidate(newsPrivateChatProvider);
                      ref.invalidate(eventsPrivateChatProvider);
                      ref.invalidate(imagesPrivateChatProvider);
                      ref.invalidate(imagesGroupProvider);
                      ref.invalidate(newsGroupProvider);
                      ref.invalidate(eventsGroupProvider);
                      ref.invalidate(requestsGroupProvider);

                      await widget.authService.deleteUser();

                      if (!mounted) return;
                      context.go('/login');
                    } else {
                      if (!mounted) return;
                      if (!buildContext.mounted) return;
                      Navigator.of(buildContext).pop();
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext newContext) {
                          return CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Failed to reauthenticate with Google account'),
                            actions: <CupertinoDialogAction>[
                              CupertinoDialogAction(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(newContext).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }),
            ],
          );
        },
      );
    } else {
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => DeleteAccountPage(
            authService: widget.authService,
            notificationService: widget.notificationService,
          ),
        ),
      );
    }
  }
}
