import 'dart:async';

import 'package:dima_project/models/category_model.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/models/article_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  List<ArticleModel> news = [];
  List<ArticleModel> categories = [];
  List<ArticleModel> sliders = [];
  static const newsApiKey = "6833714646674ccfbfa4f818a8860b31";
  Future<void> getNews() async {
    try {
      String url =
          "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=$newsApiKey";
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["title"] != null &&
              element['description'] != null &&
              element['url'] != null &&
              element['urlToImage'] != null) {
            ArticleModel articleModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
            );
            news.add(articleModel);
          }
        });
      }
    } catch (e) {
      debugPrint("Not possible to reach the server");
    }
  }

  Future<void> getCategoriesNews(String category) async {
    try {
      categories = [];
      String url =
          "https://newsapi.org/v2/everything?q=$category&apiKey=$newsApiKey";
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["title"] != null &&
              element['description'] != null &&
              element['url'] != null &&
              element['urlToImage'] != null) {
            ArticleModel showCategoryModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
            );
            categories.add(showCategoryModel);
          }
        });
      }
    } catch (e) {
      debugPrint("Not possible to reach the server");
    }
  }

  Future<void> getSliders() async {
    try {
      String url =
          "https://newsapi.org/v2/top-headlines?sources=fox-news&apiKey=$newsApiKey";
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["title"] != null &&
              element['description'] != null &&
              element['url'] != null &&
              element['urlToImage'] != null) {
            ArticleModel sliderModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
            );
            sliders.add(sliderModel);
          }
        });
      }
    } catch (e) {
      debugPrint("Not possible to reach the server");
    }
  }

  static List<CategoryModel> getCategories(List<String> userCategories) {
    List<CategoryModel> categories = [];

    for (String category in userCategories) {
      categories.add(CategoryUtil.getCategoryModel(category));
    }

    return categories;
  }

  Stream<List<ArticleModel>> getSearchedNews(String search) async* {
    try {
      List<ArticleModel> news = [];

      String url =
          "https://newsapi.org/v2/everything?q=$search&apiKey=$newsApiKey";
      var response = await http.get(Uri.parse(url));

      var jsonData = jsonDecode(response.body);

      if (jsonData['status'] == 'ok') {
        jsonData["articles"].forEach((element) {
          if (element["title"] != null &&
              element['description'] != null &&
              element['url'] != null &&
              element['urlToImage'] != null) {
            ArticleModel articleModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
            );
            news.add(articleModel);
          }
        });
      }
      yield news;
    } catch (e) {
      debugPrint("Not possible to reach the server");
      yield [];
    }
  }
}
