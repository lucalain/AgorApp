import 'package:dima_project/widgets/events/time_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  // Sample initial time for testing
  final DateTime initialTime =
      DateTime(2024, 8, 5, 14, 30); // August 5, 2024, at 14:30

  // A widget to wrap our TimePicker with the necessary MaterialApp
  Widget createWidgetForTesting({required Widget child}) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        child: Center(child: child),
      ),
    );
  }

  testWidgets('TimePicker displays clock icon', (WidgetTester tester) async {
    // Arrange: Build the TimePicker widget
    await tester.pumpWidget(createWidgetForTesting(
      child: TimePicker(
        initialTime: initialTime,
        onTimeChanged: (DateTime newTime) {}, // Dummy callback
      ),
    ));

    // Act: Find the Icon widget for the clock
    final iconFinder = find.byIcon(FontAwesomeIcons.clock);

    // Assert: Verify that the clock icon is displayed
    expect(iconFinder, findsOneWidget);
  });

  testWidgets('TimePicker shows CupertinoActionSheet on button press',
      (WidgetTester tester) async {
    // Arrange: Create a Completer to handle the onTimeChanged callback
    DateTime? newTime;
    await tester.pumpWidget(createWidgetForTesting(
      child: TimePicker(
        initialTime: initialTime,
        onTimeChanged: (DateTime time) {
          newTime = time;
        },
      ),
    ));

    // Act: Tap on the TimePicker button
    await tester.tap(find.byType(CupertinoButton));
    await tester.pumpAndSettle(); // Wait for the modal to appear

    // Assert: Verify that the CupertinoActionSheet is displayed
    expect(find.byType(CupertinoActionSheet), findsOneWidget);

    // Act: Change the time in the CupertinoDatePicker
    await tester.drag(find.byType(CupertinoDatePicker),
        const Offset(0, -100)); // Drag to change time
    await tester.pump(); // Wait for the picker to settle

    // Act: Tap the Done button
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle(); // Wait for the modal to close

    // Assert: Verify that the onTimeChanged callback was called with the new time
    expect(newTime, isNotNull); // Ensure newTime is set
  });
}
