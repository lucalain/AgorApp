import 'package:dima_project/widgets/notification_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationWidget Tests', () {
    testWidgets('NotificationWidget displays bell icon when notify is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: NotificationWidget(
            notify: true,
            notifyFunction: (bool value) {},
          ),
        ),
      );

      final iconFinder = find.byIcon(CupertinoIcons.bell);

      expect(iconFinder, findsOneWidget);
    });

    testWidgets(
        'NotificationWidget displays bell slash icon when notify is false',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: NotificationWidget(
            notify: false,
            notifyFunction: (bool value) {},
          ),
        ),
      );

      final iconFinder = find.byIcon(CupertinoIcons.bell_slash);

      expect(iconFinder, findsOneWidget);
    });

    testWidgets('Switch toggles and calls notifyFunction',
        (WidgetTester tester) async {
      bool notifyValue = false;
      await tester.pumpWidget(
        CupertinoApp(
          home: NotificationWidget(
            notify: notifyValue,
            notifyFunction: (bool value) {
              notifyValue = value;
            },
          ),
        ),
      );

      final switchFinder = find.byType(CupertinoSwitch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(notifyValue, isTrue);
      expect((tester.widget<CupertinoSwitch>(switchFinder)).value, isTrue);
    });
  });
}
