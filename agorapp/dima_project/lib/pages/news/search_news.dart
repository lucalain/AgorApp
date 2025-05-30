import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class SearchNewsPage extends StatefulWidget {
  final NewsService newsService;
  final DatabaseService databaseService;
  const SearchNewsPage(
      {super.key, required this.newsService, required this.databaseService});

  @override
  SearchNewsPageState createState() => SearchNewsPageState();
}

class SearchNewsPageState extends State<SearchNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<ArticleModel>>? _searchResults;

  void _startSearch() {
    setState(() {
      _searchResults =
          widget.newsService.getSearchedNews(_searchController.text);
    });
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
        middle: Text(
          "Search News",
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) => _startSearch(),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ArticleModel>>(
                stream: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      itemCount: 3,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: CupertinoTheme.of(context)
                              .primaryContrastingColor,
                          highlightColor: CupertinoTheme.of(context)
                              .primaryContrastingColor
                              .withOpacity(0.25),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: PhysicalModel(
                                elevation: 3.0,
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor
                                    .withOpacity(0.5),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 5.0),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: CupertinoTheme.of(context)
                                                .primaryContrastingColor,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? 230
                                                : 100,
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: CupertinoTheme.of(
                                                        context)
                                                    .primaryContrastingColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              height: 20,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.4,
                                            ),
                                            const SizedBox(
                                              height: 7.0,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: CupertinoTheme.of(
                                                        context)
                                                    .primaryContrastingColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              height: 20,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                            ),
                                          ],
                                        ),
                                      ]),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    if (_searchController.text.isNotEmpty) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? SizedBox(
                                      height: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              Constants.limitWidth
                                          ? MediaQuery.of(context).size.height *
                                              0.6
                                          : MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Image.asset(
                                        'assets/darkMode/no_news_found.png',
                                      ),
                                    )
                                  : SizedBox(
                                      height: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              Constants.limitWidth
                                          ? MediaQuery.of(context).size.height *
                                              0.6
                                          : MediaQuery.of(context).size.height *
                                              0.5,
                                      child: Image.asset(
                                          'assets/images/no_news_found.png'),
                                    ),
                              const Text("No news found",
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              const SizedBox(height: 20),
                              const Text(
                                "Digit something else to find some news",
                                style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      reverse: false,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Center(
                        child: Column(
                          children: [
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? MediaQuery.of(context).size.height *
                                            0.6
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: Image.asset(
                                        'assets/darkMode/search_news.png'))
                                : SizedBox(
                                    height: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? MediaQuery.of(context).size.height *
                                            0.6
                                        : MediaQuery.of(context).size.height *
                                            0.4,
                                    child: Image.asset(
                                        'assets/images/search_news.png')),
                            const Text("Search for news",
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 10),
                            const Text(
                              "Digit to find news",
                              style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    final articles = snapshot.data!;
                    return ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return BlogTile(
                          description: article.description,
                          imageUrl: article.urlToImage,
                          title: article.title,
                          url: article.url,
                          databaseService: widget.databaseService,
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
