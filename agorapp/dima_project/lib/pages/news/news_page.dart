import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dima_project/pages/news/all_news.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/pages/news/search_news.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/article_model.dart';
import 'package:dima_project/widgets/news/category_tile.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NewsPage extends ConsumerStatefulWidget {
  final NewsService newsService;
  const NewsPage({
    super.key,
    required this.newsService,
  });

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends ConsumerState<NewsPage> {
  List<ArticleModel>? sliders;
  List<ArticleModel>? articles;

  int numberOfNews =
      6; //it's arbitrary, we can put sliders.length (that is 10 for this api)
  int activeIndex = 0;
  final String uid = AuthService.uid;
  late final DatabaseService databaseService;
  @override
  void initState() {
    ref.read(userProvider(uid));
    databaseService = ref.read(databaseServiceProvider);
    getSliders();
    getNews();
    super.initState();
  }

  getNews() async {
    await widget.newsService.getNews();
    setState(() {
      articles = widget.newsService.news;
    });
  }

  getSliders() async {
    await widget.newsService.getSliders();
    setState(() {
      sliders = widget.newsService.sliders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider(uid));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        trailing: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => SearchNewsPage(
                        newsService: widget.newsService,
                        databaseService: databaseService)));
          },
          child: Icon(
            CupertinoIcons.search,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        middle: Text(
          "News",
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Container(
                margin: const EdgeInsets.only(left: 10.0),
                height: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 140
                    : 70,
                child: user.when(
                    data: (user) {
                      final List<String> categories = user.categories;
                      final newsCategories =
                          NewsService.getCategories(categories);
                      return ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              image: newsCategories[index].image,
                              categoryName: newsCategories[index].categoryName,
                              newsService: widget.newsService,
                              databaseService: databaseService,
                            );
                          });
                    },
                    loading: () => Shimmer.fromColors(
                        baseColor:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        highlightColor:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Stack(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    color: CupertinoTheme.of(context)
                                        .primaryContrastingColor,
                                    width: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? 240
                                        : 120,
                                    height: MediaQuery.of(context).size.width >
                                            Constants.limitWidth
                                        ? 140
                                        : 70,
                                  )),
                            ],
                          ),
                        )),
                    error: (error, _) => Text('Error: $error')),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Breaking News",
                      style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (sliders == null) {
                          return;
                        }
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AllNews(
                                      news: "Breaking",
                                      articles: sliders == null ||
                                              sliders!.isEmpty
                                          ? []
                                          : sliders!.sublist(0, numberOfNews),
                                      databaseService: databaseService,
                                    )));
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              if (sliders == null)
                Shimmer.fromColors(
                  baseColor: CupertinoTheme.of(context).primaryContrastingColor,
                  highlightColor: CupertinoTheme.of(context)
                      .primaryContrastingColor
                      .withOpacity(0.5),
                  child: Center(
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular((10)),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor
                                    .withOpacity(0.5),
                              ),
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.width >
                                      Constants.limitWidth
                                  ? 380
                                  : 180,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10)),
                            height: MediaQuery.of(context).size.width >
                                    Constants.limitWidth
                                ? 50
                                : 30,
                            width: MediaQuery.of(context).size.width * 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                (sliders!.isNotEmpty)
                    ? CarouselSlider.builder(
                        itemCount: numberOfNews,
                        itemBuilder: (context, index, realIndex) {
                          String? image = sliders![index].urlToImage;
                          String? title = sliders![index].title;
                          return buildNews(image, index, title);
                        },
                        options: CarouselOptions(
                            height: MediaQuery.of(context).size.width >
                                    Constants.limitWidth
                                ? 400
                                : 200,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            }))
                    : Center(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? 200
                              : 100,
                          child: CupertinoTheme.of(context).brightness ==
                                  Brightness.dark
                              ? Image.asset(
                                  fit: BoxFit.cover,
                                  "assets/no_news_dark.png",
                                )
                              : Image.asset(
                                  fit: BoxFit.cover,
                                  "assets/no_news_light.png",
                                ),
                        ),
                      ),
              const SizedBox(height: 30.0),
              Center(
                child: sliders == null || sliders!.isEmpty
                    ? const SizedBox.shrink()
                    : buildIndicator(),
              ),
              const SizedBox(
                height: 30.0,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Trending News",
                      style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (articles == null) {
                          return;
                        }
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AllNews(
                                    news: "Trending",
                                    articles: articles!,
                                    databaseService: databaseService)));
                      },
                      child: Text(
                        "View All",
                        style: TextStyle(
                            color: CupertinoTheme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              if (articles == null)
                ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        highlightColor: CupertinoTheme.of(context)
                            .primaryContrastingColor
                            .withOpacity(0.5),
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
                                          )),
                                      const SizedBox(width: 8.0),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: CupertinoTheme.of(
                                                          context)
                                                      .primaryContrastingColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      Constants.limitWidth
                                                  ? 40
                                                  : 20,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7.0,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: CupertinoTheme.of(
                                                          context)
                                                      .primaryContrastingColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      Constants.limitWidth
                                                  ? 20
                                                  : 10,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 7.0,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: CupertinoTheme.of(
                                                          context)
                                                      .primaryContrastingColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      Constants.limitWidth
                                                  ? 20
                                                  : 10,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
              else
                ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: articles!.length,
                    itemBuilder: (context, index) {
                      return BlogTile(
                        url: articles![index].url,
                        description: articles![index].description,
                        imageUrl: articles![index].urlToImage,
                        title: articles![index].title,
                        databaseService: databaseService,
                      );
                    })
            ],
          ),
        ),
      ),
    );
  }

  //Carousel slider
  Widget buildNews(String image, int index, String name) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ArticleView(
                          blogUrl: sliders![index].url,
                          description: sliders![index].description,
                          imageUrl: sliders![index].urlToImage,
                          title: sliders![index].title,
                          databaseService: databaseService,
                        )));
          },
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular((10)),
              child: CachedNetworkImage(
                errorListener: (value) {},
                errorWidget: (context, url, error) => Image.asset(
                  "assets/generic_news.png",
                  height: MediaQuery.of(context).size.width,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                imageUrl: image,
                height: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.only(left: 10.0),
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > Constants.limitWidth
                      ? 350
                      : 150),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            )
          ]),
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: sliders == null
          ? 0
          : sliders!.length > numberOfNews
              ? numberOfNews
              : sliders!.length,
      effect: SlideEffect(
        dotWidth: 15,
        dotHeight: 15,
        activeDotColor: CupertinoTheme.of(context).primaryColor,
      ));
}
