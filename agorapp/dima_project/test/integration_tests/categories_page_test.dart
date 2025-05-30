import 'package:dima_project/pages/categories_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/utils/category_util.dart';

void main() {
  group('CategoriesPage Tests', () {
    testWidgets('CategoriesPage displays categories without selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoriesPage(),
          ),
        ),
      );

      for (final category in CategoryUtil.categories) {
        expect(find.text(category), findsOneWidget);
        expect(find.byIcon(CategoryUtil.iconForCategory(category)),
            findsOneWidget);
        expect(
            find.byIcon(CupertinoIcons.check_mark_circled_solid), findsNothing);
      }
      expect(find.text('Categories Selection'), findsOneWidget);
    });

    testWidgets('Selected categories can be initialized',
        (WidgetTester tester) async {
      final initialSelectedCategories = [CategoryUtil.categories.first];

      await tester.pumpWidget(
        CupertinoApp(
          home: CategoriesPage(selectedCategories: initialSelectedCategories),
        ),
      );

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);
      expect(find.text(initialSelectedCategories.first), findsOneWidget);
    });
  });
}
