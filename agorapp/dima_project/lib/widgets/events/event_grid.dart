import 'package:dima_project/models/event.dart';
import 'package:flutter/cupertino.dart';

class EventGrid extends StatelessWidget {
  final Event event;
  const EventGrid({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.white,
      ),
      width: 30,
      height: 30,
      child: event.imagePath != ''
          ? Image.network(
              event.imagePath!,
              fit: BoxFit.cover,
            )
          : Image.asset(
              'assets/default_event_image.png',
            ),
    );
  }
}
