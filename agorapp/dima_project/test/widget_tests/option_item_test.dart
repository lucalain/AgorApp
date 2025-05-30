import 'package:dima_project/widgets/option_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OptionItem displays icon and text, and reacts to tap',
      (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: OptionItem(
            icon: const Icon(CupertinoIcons.home),
            text: 'Home',
            onPressed: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byIcon(CupertinoIcons.home), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.tap(find.byType(CupertinoActionSheetAction));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
