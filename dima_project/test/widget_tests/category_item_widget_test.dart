import 'package:dima_project/widgets/category_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryItemWidget Tests', () {
    testWidgets('CategoryItemWidget displays title and icon',
        (WidgetTester tester) async {
      const testTitle = 'Category 1';
      const testIcon = CupertinoIcons.add;
      final selectedCategories = <String>[];
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoryItemWidget(
              title: testTitle,
              icon: testIcon,
              onTap: () {
                wasTapped = true;
              },
              selectedCategories: selectedCategories,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsNothing);

      await tester.tap(find.byType(CategoryItemWidget));
      expect(wasTapped, true);
    });

    testWidgets('CategoryItemWidget shows checkmark when selected',
        (WidgetTester tester) async {
      const testTitle = 'Category 1';
      const testIcon = CupertinoIcons.add;
      final selectedCategories = [testTitle];
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoryItemWidget(
              title: testTitle,
              icon: testIcon,
              onTap: () {
                wasTapped = true;
              },
              selectedCategories: selectedCategories,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsOneWidget);

      await tester.tap(find.byType(CategoryItemWidget));
      expect(wasTapped, true);
    });

    testWidgets('CategoryItemWidget does not show checkmark when not selected',
        (WidgetTester tester) async {
      const testTitle = 'Category 1';
      const testIcon = CupertinoIcons.add;
      final selectedCategories = <String>[];
      bool wasTapped = false;

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: CategoryItemWidget(
              title: testTitle,
              icon: testIcon,
              onTap: () {
                wasTapped = true;
              },
              selectedCategories: selectedCategories,
            ),
          ),
        ),
      );

      expect(find.text(testTitle), findsOneWidget);
      expect(find.byIcon(testIcon), findsOneWidget);
      expect(
          find.byIcon(CupertinoIcons.check_mark_circled_solid), findsNothing);

      await tester.tap(find.byType(CategoryItemWidget));
      expect(wasTapped, true);
    });
  });
}
