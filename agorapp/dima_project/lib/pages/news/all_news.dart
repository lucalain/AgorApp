import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/news/show_all.dart';
import 'package:flutter/cupertino.dart';

class AllNews extends StatefulWidget {
  final String news;
  final List<ArticleModel> articles;
  final DatabaseService databaseService;
  const AllNews(
      {super.key,
      required this.news,
      required this.articles,
      required this.databaseService});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        middle: Text("${widget.news} News",
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.bold)),
      ),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: widget.articles.length,
              itemBuilder: (context, index) {
                return ShowAll(
                  url: widget.articles[index].url,
                  description: widget.articles[index].description,
                  image: widget.articles[index].urlToImage,
                  title: widget.articles[index].title,
                  databaseService: widget.databaseService,
                );
              })),
    );
  }
}
