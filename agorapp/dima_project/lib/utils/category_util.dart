import 'package:dima_project/models/category_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryUtil {
  static List<String> categories = [
    'Environment',
    'Cooking',
    'Culture',
    'Film & TV Series',
    'Books',
    'Gossip',
    'Music',
    'Politics',
    'Health & Wellness',
    'School & Education',
    'Sports',
    'Technology',
    'Volunteering',
  ];

  static final Map<String, CategoryModel> _categoryMap = {
    'Environment': CategoryModel(
      categoryName: 'Environment',
      image: 'assets/categories/environment.jpg',
    ),
    'Cooking': CategoryModel(
      categoryName: 'Cooking',
      image: 'assets/categories/cooking.jpg',
    ),
    'Culture': CategoryModel(
      categoryName: 'Culture',
      image: 'assets/categories/culture.jpg',
    ),
    'Film & TV Series': CategoryModel(
      categoryName: 'Film & TV Series',
      image: 'assets/categories/films.jpg',
    ),
    'Books': CategoryModel(
      categoryName: 'Books',
      image: 'assets/categories/books.jpg',
    ),
    'Gossip': CategoryModel(
      categoryName: 'Gossip',
      image: 'assets/categories/gossip.jpg',
    ),
    'Music': CategoryModel(
      categoryName: 'Music',
      image: 'assets/categories/music.jpg',
    ),
    'Politics': CategoryModel(
      categoryName: 'Politics',
      image: 'assets/categories/politics.jpg',
    ),
    'Health & Wellness': CategoryModel(
      categoryName: 'Health & Wellness',
      image: 'assets/categories/health.jpg',
    ),
    'School & Education': CategoryModel(
      categoryName: 'School & Education',
      image: 'assets/categories/school.jpg',
    ),
    'Sports': CategoryModel(
      categoryName: 'Sports',
      image: 'assets/categories/sports.jpg',
    ),
    'Technology': CategoryModel(
      categoryName: 'Technology',
      image: 'assets/categories/technology.jpg',
    ),
    'Volunteering': CategoryModel(
      categoryName: 'Volunteering',
      image: 'assets/categories/volunteering.jpg',
    ),
  };

  static CategoryModel getCategoryModel(String category) {
    return _categoryMap[category] ??
        CategoryModel(
          categoryName: 'Politics',
          image: 'assets/categories/politics.jpg',
        );
  }

  static iconForCategory(String category) {
    switch (category) {
      case 'Environment':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'Cooking':
        return FontAwesomeIcons.utensils;
      case 'Culture':
        return CupertinoIcons.globe;
      case 'Film & TV Series':
        return CupertinoIcons.film_fill;
      case 'Books':
        return CupertinoIcons.book;
      case 'Gossip':
        return CupertinoIcons.chat_bubble_2_fill;
      case 'Music':
        return CupertinoIcons.music_note;
      case 'Politics':
        return FontAwesomeIcons.landmark;
      case 'Health & Wellness':
        return CupertinoIcons.heart_fill;
      case 'School & Education':
        return CupertinoIcons.news_solid;
      case 'Sports':
        return CupertinoIcons.sportscourt;
      case 'Technology':
        return CupertinoIcons.device_phone_portrait;
      case 'Volunteering':
        return CupertinoIcons.hand_raised;
      default:
        return CupertinoIcons.question_circle;
    }
  }
}
