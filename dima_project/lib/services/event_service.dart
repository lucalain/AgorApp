import 'package:dima_project/models/event.dart';
import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventService {
  Future<LatLng> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return const LatLng(45.46284, 9.187469);
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permission is denied
        return const LatLng(45.46284, 9.187469);
      }
    }
    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  Future<String?> getAddressFromLatLng(LatLng latLng) async {
    const apiKey = '0233c5a7-dc20-4eba-8b86-970fe87df3c2';
    final url =
        'https://graphhopper.com/api/1/geocode?reverse=true&point=${latLng.latitude},${latLng.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['hits'] != null && data['hits'].isNotEmpty) {
        final address = data['hits'][0];
        final houseNumber = address['housenumber'] ?? '';
        final road = address['street'] ?? '';
        final city = address['city'] ?? address['name'] ?? '';
        final country = address['country'] ?? '';

        return [road, houseNumber, city, country]
            .where((part) => part.isNotEmpty)
            .join(', ');
      }
      return null;
    } else {
      debugPrint('Failed to fetch address: ${response.statusCode}');
      return null;
    }
  }

  static bool validateForm(
      BuildContext context,
      String name,
      String description,
      List<EventDetails> detailsList,
      List<EventDetails>? oldDetailsList) {
    if (name.isEmpty) {
      _showErrorDialog(context, 'Event name is required');
      return false;
    }
    if (name.length > 20) {
      _showErrorDialog(context, 'Event name is too long');
      return false;
    }
    if (description.isEmpty) {
      _showErrorDialog(context, 'Event description is required');
      return false;
    }
    if (description.length > 150) {
      _showErrorDialog(context, 'Event description is too long');
      return false;
    }
    for (int i = 0; i < detailsList.length; i++) {
      final EventDetails detail = detailsList[i];
      if (oldDetailsList != null && oldDetailsList.length > i) {
        continue;
      }
      if (detail.startDate == null ||
          DateFormat('dd/MM/yyyy').format(detail.startDate!).isEmpty) {
        _showErrorDialog(
            context, 'Event start date is not correct in the box ${i + 1}');
        return false;
      }
      if (detail.endDate == null ||
          DateFormat('dd/MM/yyyy').format(detail.endDate!).isEmpty) {
        _showErrorDialog(
            context, 'Event end date is not correct in the box ${i + 1}');
        return false;
      }
      if (detail.startTime == null ||
          DateFormat('HH:mm').format(detail.startTime!).isEmpty) {
        _showErrorDialog(
            context, 'Event start time is not correct in the box ${i + 1}');
        return false;
      }
      if (detail.endTime == null ||
          DateFormat('HH:mm').format(detail.endTime!).isEmpty) {
        _showErrorDialog(
            context, 'Event end time is not correct in the box ${i + 1}');
        return false;
      }
      if ((detail.location == null || detail.location!.isEmpty) &&
          detail.latlng != null) {
        _showErrorDialog(context,
            'Please wait for the location to be fetched in the box ${i + 1}');
        return false;
      }

      if (detail.location == null || detail.location!.isEmpty) {
        _showErrorDialog(
            context, 'Event location is required in the box ${i + 1}');
        return false;
      }
      if (_isEventInThePast(detail.startDate!, detail.startTime!)) {
        _showErrorDialog(
            context, 'Event in the box ${i + 1} is scheduled in the past');
        return false;
      }
      if (!_isStartDateBeforeEndDate(detail.startDate!, detail.endDate!,
          detail.startTime!, detail.endTime!)) {
        _showErrorDialog(context,
            'Event start date is after the end date in the box ${i + 1}');
        return false;
      }
    }
    return true;
  }

  static bool _isStartDateBeforeEndDate(DateTime startDate, DateTime endDate,
      DateTime startTime, DateTime endTime) {
    final startDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    return startDateTime.isBefore(endDateTime);
  }

  static bool _isEventInThePast(DateTime startDate, DateTime startTime) {
    final now = DateTime.now();
    final eventDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
    return eventDateTime.isBefore(now);
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
