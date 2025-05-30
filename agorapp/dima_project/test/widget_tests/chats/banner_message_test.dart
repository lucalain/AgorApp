import 'package:dima_project/widgets/chats/banner_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  const testSize = Size(20, 20);

  testWidgets('BannerMessage displays copied message correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Stack(
            children: [
              BannerMessage(
                size: testSize,
                canNavigate: false,
                isCopy: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Copied to clipboard'), findsOneWidget);
    expect(find.text('Image saved to Photos'), findsNothing);

    expect(find.byIcon(CupertinoIcons.rectangle_fill_on_rectangle_fill),
        findsOneWidget);
  });

  testWidgets('BannerMessage displays saved image message correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: CupertinoPageScaffold(
          child: Stack(
            children: [
              BannerMessage(
                size: testSize,
                canNavigate: false,
                isCopy: false,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Image saved to Photos'), findsOneWidget);
    expect(find.text('Copied to clipboard'), findsNothing);

    expect(find.byIcon(FontAwesomeIcons.download), findsOneWidget);
  });
}
