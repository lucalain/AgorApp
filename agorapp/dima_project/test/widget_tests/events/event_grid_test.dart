import 'package:dima_project/models/event.dart';
import 'package:dima_project/widgets/events/event_grid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('EventGrid displays event image correctly',
      (WidgetTester tester) async {
    final eventWithImage = Event(
      id: 'event_id',
      name: 'Sample Event',
      description: 'Event Description',
      imagePath: 'https://example.com/event_image.png',
      admin: 'admin_uid',
      isPublic: true,
    );

    await mockNetworkImagesFor(() async {
      // Act: Build the widget
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: EventGrid(event: eventWithImage),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byWidgetPredicate((widget) {
        return widget is Image && widget.image is NetworkImage;
      }), findsOneWidget);
    });

    final eventWithoutImage = Event(
      id: 'event_id',
      name: 'Sample Event',
      description: 'Event Description',
      imagePath: '',
      admin: 'admin_uid',
      isPublic: true,
    );

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: EventGrid(event: eventWithoutImage),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byWidgetPredicate((widget) {
      return widget is Image && widget.image is AssetImage;
    }), findsOneWidget);
  });
}
