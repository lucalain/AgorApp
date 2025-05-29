import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StartMessagingWidget displays icon and text correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: StartMessagingWidget(),
        ),
      ),
    );

    final iconFinder = find.byIcon(CupertinoIcons.chat_bubble_text);
    expect(iconFinder, findsOneWidget);

    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.size, 100);
    expect(iconWidget.color, CupertinoColors.systemGrey);

    final textFinder = find.text('Select a chat to start messaging');
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.color, CupertinoColors.systemGrey);
    expect(textWidget.style?.fontSize, 20);
    expect(textWidget.style?.fontWeight, FontWeight.bold);
  });
}
