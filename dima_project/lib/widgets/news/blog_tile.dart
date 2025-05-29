import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/pages/news/article_view.dart';

class BlogTile extends StatelessWidget {
  final String imageUrl, title, description, url;
  final DatabaseService databaseService;
  const BlogTile(
      {super.key,
      required this.description,
      required this.imageUrl,
      required this.title,
      required this.url,
      required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ArticleView(
                      blogUrl: url,
                      description: description,
                      imageUrl: imageUrl,
                      title: title,
                      databaseService: databaseService,
                    )));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: PhysicalModel(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(10),
            color: CupertinoTheme.of(context).primaryContrastingColor,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      errorListener: (value) {},
                      errorWidget: (context, url, error) => Image.asset(
                        "assets/generic_news.png",
                        height: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? 230
                            : 100,
                        width: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? MediaQuery.of(context).size.width / 3
                            : MediaQuery.of(context).size.width / 2.5,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                      imageUrl: imageUrl,
                      height: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? 230
                          : 100,
                      width: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? MediaQuery.of(context).size.width / 3
                          : MediaQuery.of(context).size.width / 2.5,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    )),
                const SizedBox(width: 8.0),
                Column(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                            fontWeight: FontWeight.w500,
                            fontSize: 17.0),
                      ),
                    ),
                    const SizedBox(
                      height: 7.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                            fontWeight: FontWeight.w500,
                            fontSize: 15.0),
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
  }
}
