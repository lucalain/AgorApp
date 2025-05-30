import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class EventDetails {
  DateTime? startDate;
  DateTime? endDate;
  String? location;
  DateTime? startTime;
  DateTime? endTime;
  LatLng? latlng;
  String? id;
  List<String>? members;
  final List<String>? requests;

  EventDetails({
    this.startDate,
    this.endDate,
    this.location,
    this.startTime,
    this.endTime,
    this.latlng,
    this.id,
    this.members,
    this.requests,
  });

  static Map<String, dynamic> toMap(EventDetails details) {
    return {
      'startDate': DateTime(
          details.startDate!.year,
          details.startDate!.month,
          details.startDate!.day,
          details.startTime!.hour,
          details.startTime!.minute),
      'endDate': DateTime(
        details.endDate!.year,
        details.endDate!.month,
        details.endDate!.day,
        details.endTime!.hour,
        details.endTime!.minute,
      ),
      'location': details.location,
      'latlng': GeoPoint(details.latlng!.latitude, details.latlng!.longitude),
      'members': details.members ?? [],
      'requests': details.requests ?? [],
    };
  }

  static EventDetails fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final DateTime startDate = snapshot['startDate'].toDate();
    final DateTime endDate = snapshot['endDate'].toDate();
    return EventDetails(
      startDate: startDate,
      endDate: endDate,
      location: snapshot['location'],
      startTime: startDate,
      endTime: endDate,
      latlng: LatLng(snapshot['latlng'].latitude, snapshot['latlng'].longitude),
      id: snapshot.id,
      members: List<String>.from(snapshot['members']),
      requests: List<String>.from(snapshot['requests']),
    );
  }
}

class Event {
  final String name;
  final String? id;
  final String admin;
  final String? imagePath;
  final String description;
  List<EventDetails>? details;
  final bool isPublic;

  final Timestamp? createdAt;

  Event({
    required this.name,
    this.id,
    required this.admin,
    this.imagePath,
    required this.description,
    required this.isPublic,
    this.createdAt,
    this.details,
  });

  static Map<String, dynamic> toMap(Event event) {
    return {
      'eventId': event.id ?? '',
      'name': event.name,
      'admin': event.admin,
      'imagePath': event.imagePath,
      'description': event.description,
      'isPublic': event.isPublic,
      'createdAt': event.createdAt,
    };
  }

  static Future<Event> fromSnapshot(DocumentSnapshot documentSnapshot) async {
    var detailsQuery =
        await documentSnapshot.reference.collection('details').get();
    List<EventDetails> details = detailsQuery.docs.isEmpty
        ? []
        : detailsQuery.docs
            .map((doc) => EventDetails.fromSnapshot(doc))
            .toList();
    return Event(
      name: documentSnapshot['name'],
      id: documentSnapshot.id,
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['imagePath'],
      description: documentSnapshot['description'],
      isPublic: documentSnapshot['isPublic'],
      createdAt: documentSnapshot['createdAt'],
      details: details,
    );
  }

  Event copyWith({required List<EventDetails> details}) {
    return Event(
      name: name,
      id: id,
      admin: admin,
      imagePath: imagePath,
      description: description,
      isPublic: isPublic,
      createdAt: createdAt,
      details: details,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Event && other.id == id;
  }

  @override
  int get hashCode {
    return id.hashCode;
  }
}
