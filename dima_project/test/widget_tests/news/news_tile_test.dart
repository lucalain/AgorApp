import 'package:dima_project/widgets/news/news_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:dima_project/pages/news/article_view.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets('NewsTile displays correctly', (WidgetTester tester) async {
    const imageUrl = 'https://via.placeholder.com/150';
    const title = 'Sample Blog Title';
    const description = 'This is a sample description for the blog tile.';
    const url = 'https://example.com';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        CupertinoApp(
          home: Column(
            children: [
              NewsTile(
                imageUrl: imageUrl,
                title: title,
                description: description,
                url: url,
                databaseService: MockDatabaseService(),
              ),
            ],
          ),
        ),
      );

      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);
      expect(find.byType(CachedNetworkImage), findsOneWidget);

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleView), findsOneWidget);
    });
  });
}
