import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dima_project/utils/category_util.dart';

void main() {
  group('CategoriesForm Tests', () {
    testWidgets('Initial state displays categories without selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoriesForm(),
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
    });

    testWidgets('Tapping category selects it', (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoriesForm(),
          ),
        ),
      );

      final firstCategory = CategoryUtil.categories.first;

      await tester.tap(find.text(firstCategory));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);
    });

    testWidgets('Tapping selected category deselects it',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoriesForm(),
          ),
        ),
      );

      final firstCategory = CategoryUtil.categories.first;

      await tester.tap(find.text(firstCategory));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);

      await tester.tap(find.text(firstCategory));
      await tester.pumpAndSettle();

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsNothing);
    });

    testWidgets('Selected categories can be initialized',
        (WidgetTester tester) async {
      final initialSelectedCategories = [CategoryUtil.categories.first];

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child:
                CategoriesForm(selectedCategories: initialSelectedCategories),
          ),
        ),
      );

      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);
      expect(find.text(initialSelectedCategories.first), findsOneWidget);
    });
  });
}
