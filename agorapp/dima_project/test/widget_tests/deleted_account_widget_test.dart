import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Displays account_canceled.png in light mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const CupertinoApp(
        home: DeletedAccountWidget(),
      ),
    );
    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/images/account_canceled.png',
        ),
        findsOneWidget);
  });

  testWidgets('Displays account_canceled.png in dark mode',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(platformBrightness: Brightness.dark),
        child: CupertinoApp(
          home: DeletedAccountWidget(),
        ),
      ),
    );

    expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Image &&
              widget.image is AssetImage &&
              (widget.image as AssetImage).assetName ==
                  'assets/darkMode/account_canceled.png',
        ),
        findsOneWidget);
  });
}
