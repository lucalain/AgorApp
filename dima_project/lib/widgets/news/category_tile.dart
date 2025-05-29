import 'package:dima_project/pages/news/category_news.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class CategoryTile extends StatelessWidget {
  final String categoryName;
  final String image;
  final NewsService newsService;
  final DatabaseService databaseService;
  const CategoryTile(
      {super.key,
      required this.image,
      required this.categoryName,
      required this.newsService,
      required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CategoryNews(
                    name: categoryName,
                    newsService: newsService,
                    databaseService: databaseService)));
      },
      child: Container(
        width: MediaQuery.of(context).size.width > Constants.limitWidth
            ? 240
            : 120,
        height:
            MediaQuery.of(context).size.width > Constants.limitWidth ? 140 : 70,
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  image,
                  width:
                      MediaQuery.of(context).size.width > Constants.limitWidth
                          ? 240
                          : 120,
                  height:
                      MediaQuery.of(context).size.width > Constants.limitWidth
                          ? 140
                          : 70,
                  fit: BoxFit.cover,
                )),
            Container(
                width: 240,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromRGBO(0, 0, 0, 0.34),
                ),
                child: Text(categoryName,
                    style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)))
          ],
        ),
      ),
    );
  }
}
