import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/event.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('Event class tests', () {
    test('EventModel constructor', () {
      EventDetails eventDetails = EventDetails(
        startDate: DateTime(2021, 1, 1),
        endDate: DateTime(2021, 1, 2),
        startTime: DateTime(2021, 1, 1, 10, 0),
        endTime: DateTime(2021, 1, 1, 12, 0),
        latlng: const LatLng(0, 0),
        members: ['admin'],
        requests: [],
        id: '321',
        location: 'location',
      );
      Event eventModel = Event(
        name: 'eventName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        createdAt: Timestamp.fromDate(DateTime(2021, 1, 1)),
        details: [eventDetails],
      );
      expect(eventModel.name, 'eventName');
      expect(eventModel.description, 'description');
      expect(eventModel.admin, 'admin');
      expect(eventModel.imagePath, 'imagePath');
      expect(eventModel.isPublic, true);
      expect(eventModel.id, '123');
      expect(eventModel.createdAt, Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(eventModel.details![0], eventDetails);
    });
    test("Test toMap", () {
      EventDetails eventDetails = EventDetails(
        startDate: DateTime(2021, 1, 1),
        endDate: DateTime(2021, 1, 2),
        startTime: DateTime(2021, 1, 1, 10, 0),
        endTime: DateTime(2021, 1, 1, 12, 0),
        latlng: const LatLng(0, 0),
        members: ['admin'],
        requests: [],
        id: '321',
        location: 'location',
      );
      Event eventModel = Event(
        name: 'eventName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        createdAt: Timestamp.fromDate(DateTime(2021, 1, 1)),
        details: [eventDetails],
      );
      Map<String, dynamic> map = Event.toMap(eventModel);
      expect(map['name'], 'eventName');
      expect(map['description'], 'description');
      expect(map['admin'], 'admin');
      expect(map['imagePath'], 'imagePath');
      expect(map['isPublic'], true);
      expect(map['eventId'], '123');
      expect(map['createdAt'], Timestamp.fromDate(DateTime(2021, 1, 1)));
    });
    test("Test fromSnapshot", () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('events').doc('eventId').set({
        'name': 'eventName',
        'description': 'description',
        'admin': 'admin',
        'imagePath': 'imagePath',
        'isPublic': true,
        'createdAt': Timestamp.fromDate(DateTime(2021, 1, 1)),
      });
      await firestore.collection('events').doc('eventId1').set({
        'name': 'eventName1',
        'description': 'description1',
        'admin': 'admin1',
        'imagePath': 'imagePath1',
        'isPublic': true,
        'createdAt': Timestamp.fromDate(DateTime(2022, 2, 2)),
      });
      await firestore
          .collection('events')
          .doc('eventId')
          .collection('details')
          .add({
        'startDate': Timestamp.fromDate(DateTime(2021, 1, 1, 10, 0)),
        'endDate': Timestamp.fromDate(DateTime(2021, 1, 2, 12, 0)),
        'latlng': const GeoPoint(0, 0),
        'members': ['admin'],
        'requests': [],
        'location': 'location',
      });

      final snapshot =
          await firestore.collection('events').doc('eventId').get();

      final snapshot1 =
          await firestore.collection('events').doc('eventId1').get();
      Event eventModel = await Event.fromSnapshot(snapshot);
      expect(eventModel.name, 'eventName');
      expect(eventModel.description, 'description');
      expect(eventModel.admin, 'admin');
      expect(eventModel.imagePath, 'imagePath');
      expect(eventModel.isPublic, true);
      expect(eventModel.id, 'eventId');
      expect(eventModel.createdAt, Timestamp.fromDate(DateTime(2021, 1, 1)));
      expect(eventModel.details![0].startDate, DateTime(2021, 1, 1, 10, 0));
      expect(eventModel.details![0].startTime, DateTime(2021, 1, 1, 10, 0));
      expect(eventModel.details![0].endDate, DateTime(2021, 1, 2, 12, 0));
      expect(eventModel.details![0].endTime, DateTime(2021, 1, 2, 12, 0));
      expect(eventModel.details![0].latlng, const LatLng(0, 0));
      expect(eventModel.details![0].members, ['admin']);
      expect(eventModel.details![0].requests, []);
      expect(eventModel.details![0].location, 'location');
      Event eventModel1 = await Event.fromSnapshot(snapshot1);
      expect(eventModel1.name, 'eventName1');
      expect(eventModel1.description, 'description1');
      expect(eventModel1.admin, 'admin1');
      expect(eventModel1.imagePath, 'imagePath1');
      expect(eventModel1.isPublic, true);
      expect(eventModel1.id, 'eventId1');
      expect(eventModel1.createdAt, Timestamp.fromDate(DateTime(2022, 2, 2)));
      expect(eventModel1.details, []);
    });

    test("Test copywith", () {
      EventDetails eventDetails = EventDetails(
        startDate: DateTime(2021, 1, 1),
        endDate: DateTime(2021, 1, 2),
        startTime: DateTime(2021, 1, 1, 10, 0),
        endTime: DateTime(2021, 1, 1, 12, 0),
        latlng: const LatLng(0, 0),
        members: ['admin'],
        requests: [],
        id: '321',
        location: 'location',
      );
      Event eventModel = Event(
        name: 'eventName',
        description: 'description',
        admin: 'admin',
        imagePath: 'imagePath',
        isPublic: true,
        id: '123',
        createdAt: Timestamp.fromDate(DateTime(2021, 1, 1)),
        details: [],
      );
      Event eventModel2 = eventModel.copyWith(
        details: [eventDetails],
      );
      expect(eventModel2.name, eventModel.name);
      expect(eventModel2.description, eventModel.description);
      expect(eventModel2.admin, eventModel.admin);
      expect(eventModel2.imagePath, eventModel.imagePath);
      expect(eventModel2.isPublic, eventModel.isPublic);
      expect(eventModel2.id, eventModel.id);
      expect(eventModel2.createdAt, eventModel.createdAt);
      expect(eventModel2.details![0], eventDetails);
    });
    test('Test EventDetails toMap', () {
      EventDetails eventDetails = EventDetails(
        startDate: DateTime(2021, 1, 1),
        endDate: DateTime(2021, 1, 2),
        startTime: DateTime(2021, 1, 1, 10, 0),
        endTime: DateTime(2021, 1, 1, 12, 0),
        latlng: const LatLng(0, 0),
        members: ['admin'],
        requests: [],
        location: 'location',
      );
      Map<String, dynamic> map = EventDetails.toMap(eventDetails);
      expect(map['startDate'], DateTime(2021, 1, 1, 10, 0));
      expect(map['endDate'], DateTime(2021, 1, 2, 12, 0));
      expect(map['latlng'], const GeoPoint(0, 0));
      expect(map['members'], ['admin']);
      expect(map['requests'], []);
      expect(map['location'], 'location');
    });
  });
}
