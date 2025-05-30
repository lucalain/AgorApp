import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/share_group_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testGroup = Group(
    id: 'group1',
    name: 'Test Group',
    description: 'This is a test group',
    imagePath: '',
    isPublic: true,
  );

  testWidgets('ShareGroupTile displays group information correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Column(
          children: [
            ShareGroupTile(
              isLast: false,
              isFirst: false,
              group: testGroup,
              onSelected: (_) {},
              active: false,
            ),
          ],
        ),
      ),
    );

    expect(find.text('Test Group'), findsOneWidget);
    expect(find.text('This is a test group'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets(
      'ShareGroupTile toggles active state and calls onSelected when tapped',
      (WidgetTester tester) async {
    String? selectedGroupId;
    await tester.pumpWidget(
      CupertinoApp(
        home: Column(
          children: [
            ShareGroupTile(
              isLast: false,
              isFirst: false,
              group: testGroup,
              onSelected: (id) {
                selectedGroupId = id;
              },
              active: false,
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.circle));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsNothing);

    expect(selectedGroupId, equals('group1'));

    await tester.tap(find.byIcon(CupertinoIcons.checkmark));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
  });

  testWidgets('ShareGroupTile starts with the correct initial active state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Column(
          children: [
            ShareGroupTile(
              isLast: false,
              isFirst: false,
              group: testGroup,
              onSelected: (_) {},
              active: true,
            ),
          ],
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsNothing);
  });
}
