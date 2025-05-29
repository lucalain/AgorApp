import 'package:dima_project/widgets/events/date_picker.dart';
import 'package:dima_project/widgets/events/time_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:dima_project/models/event.dart';
import 'package:dima_project/widgets/events/event_info_widget.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

void main() {
  group('EventInfoWidget Tests', () {
    testWidgets(
        'EventInfoWidget renders with event details and allows interaction',
        (WidgetTester tester) async {
      final detailsList = {
        0: EventDetails(
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          startTime: DateTime(2025, 1, 1, 15, 00),
          endTime: DateTime(2025, 1, 2, 15, 15),
          location: 'Some Location',
        ),
      };

      final boolMap = {0: true};

      void mockOnTap() {}
      void mockDelete(int index) {}
      void mockAdd() {}
      void mockStartDate(DateTime date, int index) {}
      void mockEndDate(DateTime date, int index) {}
      void mockStartTime(DateTime time, int index) {}
      void mockEndTime(DateTime time, int index) {}
      void mockLocation() {}

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: Column(
              children: [
                EventInfoWidget(
                  index: 0,
                  detailsList: detailsList,
                  boolMap: boolMap,
                  onTap: mockOnTap,
                  delete: mockDelete,
                  numInfos: 1,
                  startDate: mockStartDate,
                  endDate: mockEndDate,
                  startTime: mockStartTime,
                  endTime: mockEndTime,
                  add: mockAdd,
                  location: mockLocation,
                  fixedIndex: 0,
                ),
              ],
            ),
          ),
        ),
      );

      expect(
          find.text(
              DateFormat('dd/MM/yyyy').format(detailsList[0]!.startDate!)),
          findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(detailsList[0]!.startTime!)),
          findsOneWidget);
      expect(
          find.text(DateFormat('dd/MM/yyyy').format(detailsList[0]!.endDate!)),
          findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(detailsList[0]!.endTime!)),
          findsOneWidget);

      await tester.tap(find.byType(DatePicker).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(TimePicker).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.byIcon(LineAwesomeIcons.compress_solid), findsOneWidget);
      expect(find.text('Add more dates'), findsOneWidget);
    });

    testWidgets('EventInfoWidget does not render when boolMap is false',
        (WidgetTester tester) async {
      // Arrange
      final detail = EventDetails(
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
        location: 'Location',
      );

      final detailsList = {
        0: detail,
      };

      final boolMap = {0: false}; // Set to false to test the condition

      // Build the widget
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: EventInfoWidget(
              index: 0,
              detailsList: detailsList,
              boolMap: boolMap,
              onTap: () {},
              delete: (index) {},
              numInfos: 1,
              startDate: (date, index) {},
              endDate: (date, index) {},
              startTime: (time, index) {},
              endTime: (time, index) {},
              add: () {},
              location: () {},
              fixedIndex: 0,
            ),
          ),
        ),
      );
      expect(find.byType(CupertinoListTile), findsNothing);
      expect(find.text(detail.location!), findsOneWidget);
      expect(
          find.text(
              DateFormat('dd/MM/yyyy').format(detailsList[0]!.startDate!)),
          findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(detailsList[0]!.startTime!)),
          findsOneWidget);
      expect(
          find.text(DateFormat('dd/MM/yyyy').format(detailsList[0]!.endDate!)),
          findsOneWidget);
      expect(find.text(DateFormat('HH:mm').format(detailsList[0]!.endTime!)),
          findsOneWidget);
    });
  });
}
