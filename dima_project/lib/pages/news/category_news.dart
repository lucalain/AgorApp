import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/widgets/news/show_category.dart';
import 'package:shimmer/shimmer.dart';

class CategoryNews extends StatefulWidget {
  final String name;
  final NewsService newsService;
  final DatabaseService databaseService;
  const CategoryNews(
      {super.key,
      required this.name,
      required this.newsService,
      required this.databaseService});
  @override
  State<CategoryNews> createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  List<ArticleModel> categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  getCategories() async {
    await widget.newsService.getCategoriesNews(widget.name.toLowerCase());
    categories = widget.newsService.categories;
    setState(() {
      _loading = false;
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
            widget.name,
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: _loading
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        highlightColor: CupertinoTheme.of(context)
                            .primaryContrastingColor
                            .withOpacity(0.25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: MediaQuery.of(context).size.width >
                                        Constants.limitWidth
                                    ? MediaQuery.of(context).size.height * 0.6
                                    : 200,
                                width: MediaQuery.of(context).size.width,
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Container(
                              height: 20,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 5.0),
                            Container(
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 20,
                              width: MediaQuery.of(context).size.width,
                            ),
                            const SizedBox(height: 20.0),
                          ],
                        ),
                      );
                    })
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return ShowCategory(
                          url: categories[index].url,
                          description: categories[index].description,
                          image: categories[index].urlToImage,
                          databaseService: widget.databaseService,
                          title: categories[index].title);
                    })));
  }
}
