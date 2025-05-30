import 'package:dima_project/models/article_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ArticleModel constructor', () {
    ArticleModel article = ArticleModel(
      title: 'title',
      description: 'description',
      url: 'url',
      urlToImage: 'urlToImage',
    );
    expect(article.title, 'title');
    expect(article.description, 'description');
    expect(article.url, 'url');
    expect(article.urlToImage, 'urlToImage');
  });
}
