import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/widgets/news/show_category.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import '../../mocks/mock_database_service.mocks.dart';

void main() {
  testWidgets('ShowCategory widget displays correctly and navigates on tap',
      (WidgetTester tester) async {
    const image = 'https://example.com/image.jpg';
    const description = 'This is a test description for ShowCategory.';
    const title = 'Test Title for ShowCategory';
    const url = 'https://example.com/article';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: ShowCategory(
              image: image,
              description: description,
              title: title,
              url: url,
              databaseService: MockDatabaseService(),
            ),
          ),
        ),
      );

      expect(find.byType(CachedNetworkImage), findsOneWidget);
      expect(find.text(title), findsOneWidget);
      expect(find.text(description), findsOneWidget);

      await tester.tap(find.text("Test Title for ShowCategory"));
      await tester.pumpAndSettle();

      expect(find.byType(ArticleView), findsOneWidget);
    });
  });
}
