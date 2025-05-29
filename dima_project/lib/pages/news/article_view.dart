import 'package:dima_project/pages/news/share_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends ConsumerWidget {
  final String description, imageUrl, title, blogUrl;
  final DatabaseService databaseService;
  const ArticleView({
    super.key,
    required this.blogUrl,
    required this.description,
    required this.imageUrl,
    required this.title,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          leading: Navigator.canPop(context)
              ? CupertinoNavigationBarBackButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
          trailing: GestureDetector(
            child: const Icon(CupertinoIcons.share),
            onTap: () async {
              ref.invalidate(groupsProvider);
              ref.invalidate(followerProvider);
              final ids = await Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) => ShareNewsPage(
                            databaseService: databaseService,
                          )));
              if (ids is Map && ids['groups'].isNotEmpty) {
                for (var id in ids['groups']) {
                  await databaseService.shareNewsWithGroup(
                      title, description, imageUrl, blogUrl, id);
                }
              }
              if (ids is Map && ids['users'].isNotEmpty) {
                for (var id in ids['users']) {
                  await databaseService.shareNewsWithFollower(
                      title, description, imageUrl, blogUrl, id);
                }
              }
            },
          ),
        ),
        child: WebView(
          initialUrl: blogUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
