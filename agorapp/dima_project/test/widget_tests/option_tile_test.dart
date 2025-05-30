import 'package:dima_project/widgets/option_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OptionTile displays leading, title and icon',
      (WidgetTester tester) async {
    const leading = Icon(CupertinoIcons.person);
    const title = Text('Option Title');

    // Build the OptionTile widget
    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: OptionTile(
            leading: leading,
            title: title,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byWidget(leading), findsOneWidget);

    expect(find.text('Option Title'), findsOneWidget);

    expect(find.byIcon(CupertinoIcons.forward), findsOneWidget);
  });

  testWidgets('OptionTile onTap callback is triggered',
      (WidgetTester tester) async {
    bool onTapCalled = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: OptionTile(
            leading: const Icon(CupertinoIcons.person),
            title: const Text('Option Title'),
            onTap: () {
              onTapCalled = true;
            },
          ),
        ),
      ),
    );

    expect(onTapCalled, false);

    await tester.tap(find.byType(OptionTile));
    await tester.pump();

    expect(onTapCalled, true);
  });
}
