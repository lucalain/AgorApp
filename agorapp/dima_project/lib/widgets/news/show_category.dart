import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class ShowCategory extends StatelessWidget {
  final String image, description, title, url;
  final DatabaseService databaseService;
  const ShowCategory(
      {super.key,
      required this.image,
      required this.description,
      required this.databaseService,
      required this.title,
      required this.url});

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
                      imageUrl: image,
                      title: title,
                      databaseService: databaseService,
                    )));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              errorListener: (value) {},
              errorWidget: (context, url, error) => Image.asset(
                "assets/generic_news.png",
                height: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? MediaQuery.of(context).size.height * 0.6
                    : 200,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
              imageUrl: image,
              height: MediaQuery.of(context).size.width > Constants.limitWidth
                  ? MediaQuery.of(context).size.height * 0.6
                  : 200,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            maxLines: 3,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
