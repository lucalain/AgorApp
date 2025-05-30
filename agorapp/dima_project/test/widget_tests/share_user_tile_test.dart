import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/share_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testUser = UserData(
    uid: 'user1',
    username: 'testuser',
    name: 'Test',
    surname: 'User',
    imagePath: '',
    email: 'email',
    categories: ['cat1'],
  );

  testWidgets('ShareUserTile displays user information correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: ShareUserTile(
          isFirst: false,
          isLast: false,
          user: testUser,
          onSelected: (_) {},
          active: false,
        ),
      ),
    );

    expect(find.text('testuser'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets(
      'ShareUserTile toggles active state and calls onSelected when tapped',
      (WidgetTester tester) async {
    String? selectedUserId;
    await tester.pumpWidget(
      CupertinoApp(
        home: ShareUserTile(
          isFirst: false,
          isLast: false,
          user: testUser,
          onSelected: (id) {
            selectedUserId = id;
          },
          active: false,
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);

    await tester.tap(find.byIcon(CupertinoIcons.circle));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsNothing);

    expect(selectedUserId, equals('user1'));

    await tester.tap(find.byIcon(CupertinoIcons.checkmark));
    await tester.pump();

    expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
    expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
  });

  testWidgets('ShareUserTile starts with the correct initial active state',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: ShareUserTile(
          isFirst: false,
          isLast: false,
          user: testUser,
          onSelected: (_) {},
          active: true,
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.circle), findsNothing);
  });
}
