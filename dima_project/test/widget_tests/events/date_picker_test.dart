import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDateTimeCallback extends Mock {
  void call(DateTime dateTime);
}

void main() {
  testWidgets('DatePicker widget test', (WidgetTester tester) async {
    // Arrange
    DateTime initialDateTime = DateTime(2024, 8, 5);
    final mockCallback = MockDateTimeCallback();

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: DatePicker(
            initialDateTime: initialDateTime,
            onDateTimeChanged: mockCallback.call,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoDatePicker), findsOneWidget);

    DateTime newDate = DateTime(2025, 1, 1);
    await tester.tap(find.byType(CupertinoDatePicker));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      final datePicker =
          tester.widget<CupertinoDatePicker>(find.byType(CupertinoDatePicker));
      datePicker.onDateTimeChanged(newDate);
    });

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    verify(mockCallback(newDate)).called(1);
  });
}
