import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/events/event_requests_page.dart';
import 'package:dima_project/pages/events/share_event_followers_page.dart';
import 'package:dima_project/pages/events/share_event_groups_page.dart';
import 'package:dima_project/pages/events/table_calendar_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:dima_project/widgets/share_group_tile.dart';
import 'package:dima_project/widgets/share_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:mockito/mockito.dart';
import 'package:nock/nock.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_event_service.mocks.dart';
import '../mocks/mock_image_picker.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  late final MockImagePicker mockImagePicker;
  late final MockEventService mockEventService;
  late final MockNotificationService mockNotificationService;
  late final MockDatabaseService mockDatabaseService;
  final Event fakeEvent1 = Event(
      id: "123",
      name: "Test Event",
      description: "Test Description",
      admin: "Test Admin",
      imagePath: "",
      isPublic: true,
      details: [
        EventDetails(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 2),
            startTime: DateTime(2024, 1, 1, 0, 0),
            endTime: DateTime(2024, 1, 2, 1, 0),
            location: "Test Location",
            latlng: const LatLng(0, 0),
            id: "321",
            members: ["Test Admin", "uid"])
      ]);
  final Event fakeEvent2 = Event(
      id: "456",
      name: "Test Event",
      description: "Test Description",
      admin: "uid",
      imagePath: "",
      isPublic: false,
      details: [
        EventDetails(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 2),
            startTime: DateTime(2024, 1, 1, 0, 0),
            endTime: DateTime(2024, 1, 2, 1, 0),
            location: "Test Location",
            latlng: const LatLng(0, 0),
            requests: ['1', '2', '3'],
            id: "654",
            members: ["uid"])
      ]);
  final Event fakeEvent3 = Event(
      id: "789",
      name: "Test Event",
      description: "Test Description",
      admin: "uid",
      imagePath: "",
      isPublic: true,
      details: [
        EventDetails(
            requests: [],
            startDate: DateTime(3105, 1, 1),
            endDate: DateTime(3324, 1, 2),
            startTime: DateTime(3105, 1, 1, 0, 0),
            endTime: DateTime(3324, 1, 2, 1, 0),
            location: "Test Location",
            latlng: const LatLng(0, 0),
            id: "654",
            members: ["uid"])
      ]);
  group("Event tests", () {
    setUpAll(() {
      nock.init();
      mockImagePicker = MockImagePicker();
      mockEventService = MockEventService();
      mockNotificationService = MockNotificationService();
      mockDatabaseService = MockDatabaseService();
    });

    setUp(() {
      nock.cleanAll();
    });
    testWidgets("Event page renders correctly and navigation works",
        (WidgetTester tester) async {
      AuthService.setUid("uid");

      nock('https://tile.openstreetmap.org')
          .get('/{z}/{x}/{y}.png')
          .reply(200, 'OK');

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('map_launcher'),
        (MethodCall methodCall) async {
          return [
            {
              'mapName': 'Apple Maps',
              'mapType': 'apple',
            },
          ];
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent1,
            ),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            userProvider.overrideWith((ref, uid) async {
              if (uid == "uid") {
                return Future.value(UserData(
                  uid: "uuid",
                  email: "email1",
                  imagePath: "",
                  categories: [],
                  name: "name",
                  surname: "surname",
                  username: "username",
                  requests: [],
                ));
              } else {
                return Future.value(UserData(
                  uid: "Test Admin",
                  email: "email2",
                  imagePath: "",
                  categories: [],
                  name: "admin",
                  surname: "admin",
                  username: "admin",
                  requests: [],
                ));
              }
            }),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent1.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      expect(find.text("Event"), findsOneWidget);
      await tester.tap(find.byType(CupertinoListTile));
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Location: Test Location"), findsOneWidget);
      expect(find.textContaining("Add to calendar"), findsOneWidget);
      expect(find.text("Participants"), findsOneWidget);
      await tester.tap(find.text("Participants"));
      await tester.pumpAndSettle();
      expect(find.text("Participants"), findsOneWidget);
      expect(find.text("admin"), findsOneWidget);
      expect(find.text("admin admin"), findsOneWidget);
      expect(find.text("username"), findsOneWidget);
      expect(find.text("name surname"), findsOneWidget);
      expect(find.text("Host"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.location_solid));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text('Apple Maps'), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
    });

    testWidgets("Delete event works", (WidgetTester tester) async {
      AuthService.setUid("uid");
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent2,
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent2.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.text('Delete Event'));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this event?"),
          findsOneWidget);

      await tester.tap(find.text("No"));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      await tester.tap(find.text("Delete Event"));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this event?"),
          findsOneWidget);
      await tester.tap(find.text("Yes"));
      await tester.pumpAndSettle();
    });

    testWidgets("Delete detail works", (WidgetTester tester) async {
      AuthService.setUid("uid");
      when(mockNotificationService.sendEventNotification(any, any, any, any))
          .thenAnswer((_) => Future.value());
      when(mockDatabaseService.deleteDetail(any, any))
          .thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent3,
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent3.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.byType(CupertinoListTile).first);
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Location: Test Location"), findsOneWidget);
      expect(find.textContaining("Add to calendar"), findsOneWidget);
      expect(find.text("Participant"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.trash));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this date?"),
          findsOneWidget);

      await tester.tap(find.text("No"));
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.trash));
      await tester.pumpAndSettle();
      expect(find.text("Are you sure you want to delete this date?"),
          findsOneWidget);
      await tester.tap(find.text("Yes"));
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(Image).evaluate().single.widget,
          isA<Image>().having((i) => i.image, 'image', isA<AssetImage>()));
    });
    testWidgets("Add event to calendar works", (WidgetTester tester) async {
      AuthService.setUid("uid");
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('add2Cal'),
        (MethodCall methodCall) async {
          return;
        },
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent3,
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent3.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.byType(CupertinoListTile).first);
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Location: Test Location"), findsOneWidget);
      expect(find.textContaining("Add to calendar"), findsOneWidget);
      expect(find.text("Participant"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.calendar_badge_plus));
      await tester.pumpAndSettle();
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Location: Test Location"), findsOneWidget);
      expect(find.textContaining("Add to calendar"), findsOneWidget);
      expect(find.text("Participant"), findsOneWidget);
    });
    group("Joining events functions correctly", () {
      testWidgets("Joining a public event before it starts functions correctly",
          (WidgetTester tester) async {
        AuthService.setUid("uid1");
        when(mockDatabaseService.toggleEventJoin(any, any)).thenAnswer(
          (_) => Future.value(),
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              eventProvider.overrideWith(
                (ref, id) async => fakeEvent3,
              ),
            ],
            child: CupertinoApp(
              home: EventPage(
                imagePicker: mockImagePicker,
                eventService: mockEventService,
                eventId: fakeEvent3.id!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text("Event"), findsOneWidget);
        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Test Description"), findsOneWidget);
        expect(
            find.text(
                '${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent3.details![0].endDate!)}'),
            findsOneWidget);
        expect(find.text('Test Location'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
        await tester.tap(find.byType(CupertinoListTile).first);
        await tester.pumpAndSettle();
        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Location: Test Location"), findsOneWidget);
        expect(find.textContaining("Add to calendar"), findsOneWidget);
        expect(find.text("Participant"), findsOneWidget);
        await tester.tap(find.text("Subscribe"));
        await tester.pumpAndSettle();
        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Location: Test Location"), findsOneWidget);
        expect(find.textContaining("Add to calendar"), findsOneWidget);
        expect(find.text("Participant"), findsOneWidget);
      });
      testWidgets("Joining a public event after it starts is prevented",
          (WidgetTester tester) async {
        AuthService.setUid("uid1");
        final Event event = Event(
            id: "789",
            name: "Test Event",
            description: "Test Description",
            admin: "uid",
            imagePath: "",
            isPublic: true,
            details: [
              EventDetails(
                  requests: [],
                  startDate: DateTime(2000, 1, 1),
                  endDate: DateTime(2001, 1, 2),
                  startTime: DateTime(2000, 1, 1, 0, 0),
                  endTime: DateTime(2001, 1, 2, 1, 0),
                  location: "Test Location",
                  latlng: const LatLng(0, 0),
                  id: "654",
                  members: ["uid"])
            ]);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              eventProvider.overrideWith(
                (ref, id) async => event,
              ),
            ],
            child: CupertinoApp(
              home: DetailEventPage(
                eventId: event.id!,
                detailId: event.details![0].id!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Location: Test Location"), findsOneWidget);
        expect(find.textContaining("Add to calendar"), findsOneWidget);
        expect(find.text("Participant"), findsOneWidget);
        expect(find.text("Subscribe"), findsNothing);
      });
      testWidgets("Joining a deleted event is prevented",
          (WidgetTester tester) async {
        AuthService.setUid("uid1");

        when(mockDatabaseService.toggleEventJoin(any, any)).thenAnswer(
            (_) => throw Exception('Event or date has been deleted'));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              eventProvider.overrideWith(
                (ref, id) async => fakeEvent3,
              ),
            ],
            child: CupertinoApp(
              home: DetailEventPage(
                eventId: fakeEvent3.id!,
                detailId: fakeEvent3.details![0].id!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Location: Test Location"), findsOneWidget);
        expect(find.textContaining("Add to calendar"), findsOneWidget);
        expect(find.text("Participant"), findsOneWidget);
        await tester.tap(find.text("Subscribe"));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text("Event or date has been deleted"), findsOneWidget);
        expect(find.text("Error"), findsOneWidget);
        await tester.tap(find.text("Ok"));
        await tester.pumpAndSettle();
      });
    });
    testWidgets("Edit event page works correctly", (WidgetTester tester) async {
      AuthService.setUid("uid");
      when(mockDatabaseService.getGroups(any)).thenAnswer(
        (_) => Future.value([]),
      );

      when(mockDatabaseService.updateEvent(any, any, any, any)).thenAnswer((_) {
        return Future.value();
      });
      when(mockEventService.getCurrentLocation())
          .thenAnswer((_) => Future.value(const LatLng(0, 0)));
      when(mockEventService.getAddressFromLatLng(any))
          .thenAnswer((_) => Future.value("Test Location"));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent2,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent2.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.text("Edit Event"));
      await tester.pumpAndSettle();
      expect(find.text("Edit Event"), findsOneWidget);
      await tester.tap(find.byType(ButtonImageWidget));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.text("Set New Photo"), findsOneWidget);
      expect(find.text("Remove Photo"), findsOneWidget);
      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(CupertinoTextField).at(0), "");
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Event name is required"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(0), "Test Event1");

      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsOneWidget);

      await tester.tap(find.text("Add more dates"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsNWidgets(6));

      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.map_pin_ellipse));
      await tester.pumpAndSettle();
      expect(find.text("Select location"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.calendar).first);
      await tester.pumpAndSettle();
      await tester.drag(
          find.text(DateTime.now().year.toString()), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.calendar).last);
      await tester.pumpAndSettle();
      await tester.drag(
          find.text(DateTime.now().year.toString()), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.clock).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.clock).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.trash));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoListTile), findsOneWidget);

      expect(find.byIcon(CupertinoIcons.lock_fill), findsOneWidget);
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.lock_open_fill), findsOneWidget);

      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
    });
    testWidgets("Table Calendar Page navigation functions correctly",
        (WidgetTester tester) async {
      AuthService.setUid("uid");
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final Event event1 = Event(
          id: "456",
          name: "Event1",
          description: "Test Description",
          admin: "uid",
          imagePath: "",
          isPublic: true,
          details: [
            EventDetails(
                startDate:
                    DateTime(DateTime.now().year, DateTime.now().month, 1),
                endDate: DateTime(DateTime.now().year, DateTime.now().month, 2),
                startTime: DateTime(
                    DateTime.now().year, DateTime.now().month, 1, 0, 0),
                endTime: DateTime(
                    DateTime.now().year, DateTime.now().month, 2, 1, 0),
                location: "Test Location",
                latlng: const LatLng(0, 0),
                id: "654",
                members: ["uid"])
          ]);
      final Event event2 = Event(
          id: "456",
          name: "Event2",
          description: "Test Description",
          admin: "uid",
          imagePath: "",
          isPublic: true,
          details: [
            EventDetails(
                startDate:
                    DateTime(DateTime.now().year, DateTime.now().month, 13),
                endDate:
                    DateTime(DateTime.now().year, DateTime.now().month, 15),
                startTime: DateTime(
                    DateTime.now().year, DateTime.now().month, 13, 0, 0),
                endTime: DateTime(
                    DateTime.now().year, DateTime.now().month, 15, 1, 0),
                location: "Test Location",
                latlng: const LatLng(0, 0),
                id: "654",
                members: ["uid"])
          ]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => event1,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
            createdEventsProvider.overrideWith(
              (ref, uid) async => [event2],
            ),
            joinedEventsProvider.overrideWith(
              (ref, uid) async => [event1],
            ),
          ],
          child: CupertinoApp(
            home: TableCalendarPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Calendar"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.add_circled));
      await tester.pumpAndSettle();
      expect(find.text("Create Event"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.text("Calendar"), findsOneWidget);
      await tester.tap(find.text("1"));

      await tester.pumpAndSettle();
      expect(find.text("Event1"), findsOneWidget);
      await tester.tap(find.byType(CupertinoListTile));
      await tester.pumpAndSettle();
      expect(find.text("Event1"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text("14"));
      await tester.pumpAndSettle();
      expect(find.text("Event2"), findsOneWidget);

      debugDefaultTargetPlatformOverride = null;
    });
    testWidgets("Create Event Page test", (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      when(mockEventService.getCurrentLocation())
          .thenAnswer((_) => Future.value(const LatLng(0, 0)));
      when(mockEventService.getAddressFromLatLng(any))
          .thenAnswer((_) => Future.value("Test Location"));
      when(mockDatabaseService.getGroups(any)).thenAnswer(
        (_) => Future.value([
          Group(
              name: "name",
              id: "id",
              isPublic: true,
              members: ["uid"],
              admin: "uid",
              imagePath: "",
              description: "description")
        ]),
      );
      when(mockDatabaseService.createEvent(any, any, any, any))
          .thenAnswer((_) => Future.value());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            followerProvider.overrideWith(
              (ref, uid) async => [],
            ),
            createdEventsProvider.overrideWith(
              (ref, uid) async => [],
            ),
            joinedEventsProvider.overrideWith(
              (ref, uid) async => [],
            ),
            groupsProvider.overrideWith(
              (ref, uid) async => [
                Group(
                    name: "name",
                    id: "id",
                    isPublic: true,
                    members: ["uid"],
                    admin: "uid",
                    imagePath: "",
                    description: "description")
              ],
            ),
          ],
          child: CupertinoApp(
            home: TableCalendarPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Calendar"), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.add_circled));
      await tester.pumpAndSettle();
      expect(find.text("Create Event"), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -300));

      await tester.pumpAndSettle();
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Validation Error"), findsOneWidget);
      expect(find.text("Event name is required"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, 300));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byType(CupertinoTextField).at(0), "Test Event");
      await tester.enterText(
          find.byType(CupertinoTextField).at(1), "Test Description");
      await tester.tap(find.byIcon(FontAwesomeIcons.calendar).first);
      await tester.pumpAndSettle();
      await tester.drag(
          find.text(DateTime.now().year.toString()), const Offset(0, -300));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(FontAwesomeIcons.calendar).last);
      await tester.pumpAndSettle();
      await tester.drag(
          find.text(DateTime.now().year.toString()), const Offset(0, -400));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.clock).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(FontAwesomeIcons.clock).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text("Done").last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.map_pin_ellipse));
      await tester.pumpAndSettle();
      expect(find.text("Select location"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.map_pin_ellipse));
      await tester.pumpAndSettle();
      expect(find.text("Select location"), findsOneWidget);
      await tester.tap(find.text("Select location"));
      await tester.pumpAndSettle();
      expect(find.text("Test Location"), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Add more dates"));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView).first, const Offset(0, -300));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(CupertinoIcons.trash).last);
      await tester.pumpAndSettle();

      await tester.tap(find.text("Share with Followers"));
      await tester.pumpAndSettle();
      expect(find.text("Share with Followers"), findsOneWidget);
      expect(find.text("No followers"), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text("Share with Groups"));
      await tester.pumpAndSettle();
      expect(find.text("name"), findsOneWidget);
      expect(find.text("Share with Groups"), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);

      expect(find.byType(CupertinoListTile), findsOneWidget);

      await tester.tap(find.text("name"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      await tester.tap(find.text("name"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
      await tester.tap(find.byType(CupertinoNavigationBarBackButton));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.lock_open_fill), findsOneWidget);
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.lock_fill), findsOneWidget);
      await tester.tap(find.text("Done"));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.text("Event created successfully!"), findsOneWidget);
      await tester.tap(find.text("Ok"));
      await tester.pumpAndSettle();
      expect(find.text("Calendar"), findsOneWidget);
      debugDefaultTargetPlatformOverride = null;
    });
    group("Event Requests Page tests", () {
      testWidgets("Event Request Page correctly displays No Event Requests",
          (WidgetTester tester) async {
        AuthService.setUid("uid");
        final MockDatabaseService mockDatabaseService = MockDatabaseService();

        await tester.pumpWidget(
          ProviderScope(
            child: CupertinoApp(
              home: EventRequestsPage(
                eventId: "123",
                requests: const [],
                detailId: '1',
                databaseService: mockDatabaseService,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text("Event Requests"), findsOneWidget);
        expect(find.text("No Event Requests"), findsOneWidget);
      });

      testWidgets("Event Requests Page works correctly",
          (WidgetTester tester) async {
        AuthService.setUid("uid");
        when(mockDatabaseService.getGroups(any)).thenAnswer(
          (_) => Future.value([]),
        );

        when(mockDatabaseService.updateEvent(any, any, any, any))
            .thenAnswer((_) {
          return Future.value();
        });
        when(mockDatabaseService.acceptEventRequest(any, any, "1"))
            .thenAnswer((_) => Future.value());
        when(mockDatabaseService.acceptEventRequest(any, any, "3"))
            .thenAnswer((_) {
          throw Exception("User deleted his account");
        });
        when(mockDatabaseService.denyEventRequest(any, any, any))
            .thenAnswer((_) => Future.value());
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              databaseServiceProvider.overrideWithValue(mockDatabaseService),
              eventProvider.overrideWith(
                (ref, id) async => fakeEvent2,
              ),
              notificationServiceProvider
                  .overrideWithValue(mockNotificationService),
              followingProvider.overrideWith(
                (ref, uid) async => [],
              ),
              followerProvider.overrideWith(
                (ref, uid) async => [],
              ),
              userProvider.overrideWith((ref, uid) async {
                if (uid == "1") {
                  return Future.value(UserData(
                    uid: "1",
                    email: "email1",
                    imagePath: "",
                    categories: [],
                    name: "name1",
                    surname: "surname1",
                    username: "username1",
                    requests: [],
                  ));
                } else if (uid == "2") {
                  return Future.value(UserData(
                    uid: "2",
                    email: "email2",
                    imagePath: "",
                    categories: [],
                    name: "name2",
                    surname: "surname2",
                    username: "username2",
                    requests: [],
                  ));
                } else {
                  return Future.value(UserData(
                    uid: "3",
                    email: "email3",
                    imagePath: "",
                    categories: [],
                    name: "name3",
                    surname: "surname3",
                    username: "username3",
                    requests: [],
                  ));
                }
              }),
            ],
            child: CupertinoApp(
              home: EventPage(
                imagePicker: mockImagePicker,
                eventService: mockEventService,
                eventId: fakeEvent2.id!,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text("Event"), findsOneWidget);
        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Test Description"), findsOneWidget);
        expect(
            find.text(
                '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
            findsOneWidget);
        expect(find.text('Test Location'), findsOneWidget);
        expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
        await tester.tap(find.byType(CupertinoListTile).first);
        await tester.pumpAndSettle();
        expect(find.text("Test Event"), findsOneWidget);
        expect(find.text("Location: Test Location"), findsOneWidget);
        expect(find.textContaining("Add to calendar"), findsOneWidget);
        await tester.tap(find.text("Requests"));
        await tester.pumpAndSettle();
        expect(find.text("Event Requests"), findsOneWidget);
        expect(find.byType(CupertinoListTile), findsNWidgets(3));
        expect(find.text("username1"), findsOneWidget);
        expect(find.text("name1 surname1"), findsOneWidget);
        expect(find.text("username2"), findsOneWidget);
        expect(find.text("name2 surname2"), findsOneWidget);
        expect(find.text("username3"), findsOneWidget);
        expect(find.text("name3 surname3"), findsOneWidget);
        await tester.tap(find.text("Accept").first);
        await tester.pumpAndSettle();
        await tester.tap(find.text("Deny").first);
        await tester.pumpAndSettle();
        await tester.tap(find.text("Accept"));
        await tester.pumpAndSettle();
        expect(find.byType(CupertinoAlertDialog), findsOneWidget);
        expect(find.text("User deleted his account"), findsOneWidget);
        await tester.tap(find.text("Ok"));
        await tester.pumpAndSettle();
        expect(find.text("Event Requests"), findsOneWidget);
        expect(find.text("No Event Requests"), findsOneWidget);

        await tester.tap(find.byType(CupertinoNavigationBarBackButton));
        await tester.pumpAndSettle();
        expect(find.text("Test Event"), findsOneWidget);
      });
    });
    testWidgets("Share Event Page works correctly",
        (WidgetTester tester) async {
      AuthService.setUid("uid");

      when(mockDatabaseService.sendEventsToPrivateChats(any, any))
          .thenAnswer((_) {
        return Future.value();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseServiceProvider.overrideWithValue(mockDatabaseService),
            eventProvider.overrideWith(
              (ref, id) async => fakeEvent2,
            ),
            notificationServiceProvider
                .overrideWithValue(mockNotificationService),
            followingProvider.overrideWith(
              (ref, uid) async => [],
            ),
            groupsProvider.overrideWith(
              (ref, uid) async => [
                Group(
                    name: "name",
                    id: "id",
                    isPublic: true,
                    members: ["uid"],
                    admin: "uid",
                    imagePath: "",
                    description: "description")
              ],
            ),
            followerProvider.overrideWith((ref, uid) async {
              return Future.value([
                UserData(
                  uid: "1",
                  email: "email1",
                  imagePath: "",
                  categories: [],
                  name: "name1",
                  surname: "surname1",
                  username: "username1",
                  requests: [],
                ),
                UserData(
                  uid: "2",
                  email: "email2",
                  imagePath: "",
                  categories: [],
                  name: "name2",
                  surname: "surname2",
                  username: "username2",
                  requests: [],
                ),
                UserData(
                  uid: "3",
                  email: "email3",
                  imagePath: "",
                  categories: [],
                  name: "name3",
                  surname: "surname3",
                  username: "username3",
                  requests: [],
                )
              ]);
            }),
          ],
          child: CupertinoApp(
            home: EventPage(
              imagePicker: mockImagePicker,
              eventService: mockEventService,
              eventId: fakeEvent2.id!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.share));
      await tester.pumpAndSettle();
      expect(find.text("Send To"), findsOneWidget);
      await tester.tap(find.text("name"));
      expect(find.byIcon(CupertinoIcons.circle), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "hhh");
      await tester.pumpAndSettle();
      expect(find.text("No groups found"), findsOneWidget);

      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.text("No followers found"), findsOneWidget);
      await tester.enterText(find.byType(CupertinoSearchTextField), "");
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.circle), findsNWidgets(3));

      await tester.tap(find.text("username1"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      await tester.tap(find.text("Followers"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.circle), findsNWidgets(2));

      await tester.tap(find.text("username1"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark), findsNothing);
      await tester.tap(find.text("username1"));
      await tester.pumpAndSettle();
      expect(find.byIcon(CupertinoIcons.checkmark), findsOneWidget);
      await tester.tap(find.byIcon(CupertinoIcons.paperplane));
      await tester.pumpAndSettle();
      expect(find.text("Event"), findsOneWidget);
      expect(find.text("Test Event"), findsOneWidget);
      expect(find.text("Test Description"), findsOneWidget);
      expect(
          find.text(
              '${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].startDate!)} - ${DateFormat('dd/MM/yyyy').format(fakeEvent1.details![0].endDate!)}'),
          findsOneWidget);
      expect(find.text('Test Location'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.circle_fill), findsOneWidget);
    });
  });
  group('ShareEventFollowersPage Tests', () {
    testWidgets(
        'ShareEventFollowersPage displays no followers when followers list is empty',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            followerProvider.overrideWith(
              (ref, uid) async => Future.value([]),
            ),
          ],
          child: const CupertinoApp(
              home: ShareEventFollowersPage(invitedUsers: [])),
        ),
      );

      await tester.pump();

      expect(find.text('No followers'), findsOneWidget);
    });
    testWidgets(
        'ShareEventFollowersPage displays no followers when followers list is empty in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            followerProvider.overrideWith(
              (ref, uid) async => Future.value([]),
            ),
          ],
          child: const CupertinoApp(
              home: MediaQuery(
                  data: MediaQueryData(
                    platformBrightness: Brightness.dark,
                  ),
                  child: ShareEventFollowersPage(invitedUsers: []))),
        ),
      );

      await tester.pump();

      expect(find.text('No followers'), findsOneWidget);
    });
    testWidgets('ShareEventFollowersPage displays followers list',
        (WidgetTester tester) async {
      final followers = [
        UserData(
            uid: '1',
            username: 'user1',
            imagePath: '',
            categories: [],
            email: 'email@gmail.com',
            name: 'name',
            surname: 'surname',
            requests: []),
        UserData(
            uid: '2',
            username: 'user2',
            imagePath: '',
            categories: [],
            email: 'email2@gmail.com',
            name: 'name2',
            surname: 'surname2',
            requests: []),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            followerProvider.overrideWith((ref, uid) async {
              return followers;
            }),
          ],
          child: const CupertinoApp(
              home: ShareEventFollowersPage(invitedUsers: [])),
        ),
      );

      await tester.pump();

      expect(find.byType(ShareUserTile), findsNWidgets(2));
      expect(find.text('user1'), findsOneWidget);
      expect(find.text('user2'), findsOneWidget);
    });

    testWidgets(
        'ShareEventFollowersPage filters followers based on search input',
        (WidgetTester tester) async {
      final followers = [
        UserData(
            uid: '1',
            username: 'user1',
            imagePath: '',
            categories: [],
            email: 'email@gmail.com',
            name: 'name',
            surname: 'surname',
            requests: []),
        UserData(
            uid: '2',
            username: 'user2',
            imagePath: '',
            categories: [],
            email: 'email2@gmail.com',
            name: 'name2',
            surname: 'surname2',
            requests: []),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            followerProvider.overrideWith(
              (ref, uid) async => followers,
            ),
          ],
          child: const CupertinoApp(
              home: ShareEventFollowersPage(invitedUsers: [])),
        ),
      );

      await tester.pump();

      await tester.enterText(find.byType(CupertinoSearchTextField), 'user2');
      await tester.pumpAndSettle();

      expect(find.byType(ShareUserTile), findsOneWidget);
      expect(find.text('user2'), findsNWidgets(2));
      expect(find.text('user1'), findsNothing);

      await tester.enterText(find.byType(CupertinoSearchTextField), 'hhh');
      await tester.pumpAndSettle();
      expect(find.byType(ShareUserTile), findsNothing);
      expect(find.text('user2'), findsNothing);
      expect(find.text('user1'), findsNothing);
    });

    testWidgets('ShareEventFollowersPage toggles selected user',
        (WidgetTester tester) async {
      List<String> users = [];
      final followers = [
        UserData(
            uid: '1',
            username: 'user1',
            imagePath: '',
            categories: [],
            email: 'email@gmail.com',
            name: 'name',
            surname: 'surname',
            requests: []),
        UserData(
            uid: '2',
            username: 'user2',
            imagePath: '',
            categories: [],
            email: 'email2@gmail.com',
            name: 'name2',
            surname: 'surname2',
            requests: []),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            followerProvider.overrideWith(
              (ref, uid) async => followers,
            ),
          ],
          child:
              CupertinoApp(home: ShareEventFollowersPage(invitedUsers: users)),
        ),
      );

      await tester.pump();
      expect(find.byIcon(CupertinoIcons.circle), findsNWidgets(2));

      await tester.tap(find.text('user1'));
      await tester.pumpAndSettle();

      expect(find.byType(ShareUserTile), findsNWidgets(2));
      expect(find.byIcon(CupertinoIcons.check_mark), findsOneWidget);
    });
  });

  group('ShareEventsGroupPage Tests', () {
    testWidgets(
        'ShareEventsGroupPage displays no groups message when there are no groups',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupsProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: ShareEventsGroupPage(
              groupIds: const [],
              databaseService: MockDatabaseService(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('No groups'), findsOneWidget);
    });
    testWidgets(
        'ShareEventsGroupPage displays no groups message when there are no groups in dark mode',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupsProvider.overrideWith(
              (ref, uid) async => [],
            ),
          ],
          child: CupertinoApp(
            home: MediaQuery(
              data: const MediaQueryData(
                platformBrightness: Brightness.dark,
              ),
              child: ShareEventsGroupPage(
                groupIds: const [],
                databaseService: MockDatabaseService(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('No groups'), findsOneWidget);
    });

    testWidgets(
        'ShareEventsGroupPage displays groups correctly when data is available',
        (WidgetTester tester) async {
      final mockGroups = [
        Group(
            id: '1',
            name: 'Group 1',
            isPublic: true,
            imagePath: '',
            description: 'Description1'),
        Group(
            id: '2',
            name: 'Group 2',
            isPublic: true,
            imagePath: '',
            description: 'Description2'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupsProvider.overrideWith(
              (ref, uid) async => mockGroups,
            ),
          ],
          child: CupertinoApp(
            home: ShareEventsGroupPage(
              groupIds: const [],
              databaseService: MockDatabaseService(),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(ShareGroupTile), findsNWidgets(2));
      expect(find.text('Group 1'), findsOneWidget);
      expect(find.text('Group 2'), findsOneWidget);
    });

    testWidgets('ShareEventsGroupPage filters groups based on search input',
        (WidgetTester tester) async {
      final mockGroups = [
        Group(
            id: '1',
            name: 'Group 1',
            isPublic: true,
            imagePath: '',
            description: 'Description1'),
        Group(
            id: '2',
            name: 'Test Group',
            isPublic: true,
            imagePath: '',
            description: 'Description2'),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            groupsProvider.overrideWith(
              (ref, uid) => (mockGroups),
            ),
          ],
          child: CupertinoApp(
            home: ShareEventsGroupPage(
              groupIds: const [],
              databaseService: MockDatabaseService(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.enterText(find.byType(CupertinoSearchTextField), 'Test');
      await tester.pump();

      expect(find.text('Test Group'), findsOneWidget);
      expect(find.text('Group 1'), findsNothing);
      await tester.enterText(find.byType(CupertinoSearchTextField), 'hhh');
      await tester.pump();
      expect(find.byType(ShareGroupTile), findsNothing);
    });
  });
}
