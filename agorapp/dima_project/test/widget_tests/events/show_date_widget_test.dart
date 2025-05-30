import 'package:dima_project/widgets/events/show_date_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final DateTime testDate = DateTime(2024, 8, 5); // August 5, 2024
  final DateTime testTime = DateTime(2024, 8, 5, 14, 30); // 14:30 (2:30 PM)

  Widget createWidgetForTesting({required Widget child}) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: Center(child: child),
      ),
    );
  }

  testWidgets('ShowDateWidget displays formatted date and time',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: ShowDateWidget(date: testDate, time: testTime)));

    final dateFinder = find.text(DateFormat('yMMM').format(testDate));
    final dayFinder =
        find.text('${DateFormat('EEE').format(testDate)} ${testDate.day}');
    final timeFinder = find.text(DateFormat('HH:mm').format(testTime));

    expect(dateFinder, findsOneWidget);
    expect(dayFinder, findsOneWidget);
    expect(timeFinder, findsOneWidget);
  });

  testWidgets('ShowDateWidget displays calendar icon',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetForTesting(
        child: ShowDateWidget(date: testDate, time: testTime)));

    final iconFinder = find.byType(Image);

    expect(iconFinder, findsOneWidget);
  });
}
