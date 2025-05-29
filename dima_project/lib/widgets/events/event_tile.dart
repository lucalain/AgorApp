import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class EventTile extends ConsumerWidget {
  final Event event;
  const EventTile({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String uid = AuthService.uid;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.invalidate(eventProvider(event.id!));
              ref.invalidate(joinedEventsProvider(uid));
              ref.invalidate(createdEventsProvider(uid));
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => EventPage(
                    eventId: event.id!,
                    imagePicker: ImagePicker(),
                    eventService: EventService(),
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > Constants.limitWidth
                      ? 8.0
                      : 0.0),
              child: CupertinoListTile(
                leading: Transform.scale(
                    scale:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 1.3
                            : 1,
                    child: CreateImageUtils.getEventImage(
                        event.imagePath!, context,
                        small: true)),
                title: Text(
                  event.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? 20
                          : 17),
                ),
                subtitle: Text("Description: ${event.description}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width >
                                Constants.limitWidth
                            ? 15
                            : 12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
