import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/events/event_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/event.dart';
import 'package:latlong2/latlong.dart';

import '../../mocks/mock_database_service.mocks.dart';
import '../../mocks/mock_notification_service.mocks.dart';

void main() {
  final Event testEvent = Event(
      id: '123',
      name: 'Event',
      description: 'Description',
      imagePath: '',
      admin: 'uid',
      isPublic: true,
      details: [
        EventDetails(
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          startTime: DateTime.now(),
          endTime: DateTime.now(),
          location: 'Location',
          latlng: const LatLng(0, 0),
          members: ['uid'],
        ),
      ]);
  testWidgets(
      'EventTile displays event name and description correctly and navigates on tap',
      (WidgetTester tester) async {
    AuthService.setUid('uid');
    await tester.pumpWidget(ProviderScope(
      overrides: [
        eventProvider.overrideWith(
          (ref, eventId) => testEvent,
        ),
        databaseServiceProvider.overrideWithValue(MockDatabaseService()),
        notificationServiceProvider
            .overrideWithValue(MockNotificationService()),
      ],
      child: CupertinoApp(
        home: CupertinoPageScaffold(
          child: EventTile(event: testEvent),
        ),
      ),
    ));

    expect(find.text('Event'), findsOneWidget);
    expect(find.text('Description: Description'), findsOneWidget);

    await tester.tap(find.text('Event'));
    await tester.pumpAndSettle();

    expect(find.byType(EventPage), findsOneWidget);
  });
}
