import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/widgets/messages/event_deleted_message_tile.dart';
import 'package:dima_project/utils/message_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class EventMessageTile extends ConsumerStatefulWidget {
  final Message message;
  final String? senderUsername;
  final DatabaseService databaseService;

  const EventMessageTile({
    required this.message,
    this.senderUsername,
    required this.databaseService,
    super.key,
  });

  @override
  EventMessageTileState createState() => EventMessageTileState();
}

class EventMessageTileState extends ConsumerState<EventMessageTile> {
  late final DatabaseService databaseService;
  @override
  void initState() {
    ref.read(eventProvider(widget.message.content));
    databaseService = widget.databaseService;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.message.content));
    return event.when(
        data: (event) {
          return GestureDetector(
            onLongPress: () => MessageUtils.showBottomSheet(
              context,
              widget.message,
              databaseService,
              showCustomSnackbar: null,
            ),
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.only(
                    top: 7,
                    bottom: 7,
                    left: widget.message.sentByMe! ? 24 : 0,
                    right: widget.message.sentByMe! ? 0 : 24,
                  ),
                  alignment: widget.message.sentByMe!
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: widget.message.sentByMe!
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!widget.message.sentByMe! &&
                          widget.message.isGroupMessage)
                        Padding(
                          padding: const EdgeInsets.only(right: 3),
                          child: CreateImageUtils.getUserImage(
                            widget.message.senderImage!,
                            0,
                          ),
                        ),
                      Container(
                        margin: widget.message.sentByMe!
                            ? const EdgeInsets.only(left: 30)
                            : const EdgeInsets.only(right: 30),
                        padding: const EdgeInsets.only(
                            top: 8, left: 15, right: 8, bottom: 10),
                        decoration: BoxDecoration(
                          borderRadius: widget.message.sentByMe!
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                )
                              : const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                          color: widget.message.sentByMe!
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.systemGrey,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (!widget.message.sentByMe! &&
                                widget.message.isGroupMessage)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      widget.senderUsername!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: widget.message.sentByMe!
                                            ? CupertinoColors.white
                                            : CupertinoColors.black,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ref.invalidate(eventProvider(event.id!));
                                    ref.invalidate(
                                        joinedEventsProvider(AuthService.uid));
                                    ref.invalidate(
                                        createdEventsProvider(AuthService.uid));
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => EventPage(
                                          eventId: widget.message.content,
                                          imagePicker: ImagePicker(),
                                          eventService: EventService(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Transform.scale(
                                            scale: 1.4,
                                            child:
                                                CreateImageUtils.getEventImage(
                                              event.imagePath!,
                                              context,
                                              small: true,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  event.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: widget
                                                            .message.sentByMe!
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 150,
                                                child: Text(
                                                  event.description,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    color: widget
                                                            .message.sentByMe!
                                                        ? CupertinoColors.white
                                                        : CupertinoColors.black,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    event.details!
                                                        .map((e) =>
                                                            e.members!.length)
                                                        .reduce((a, b) => a + b)
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: widget
                                                              .message.sentByMe!
                                                          ? CupertinoColors
                                                              .white
                                                          : CupertinoColors
                                                              .black,
                                                    ),
                                                  ),
                                                  event.details!
                                                              .map((e) => e
                                                                  .members!
                                                                  .length)
                                                              .reduce((a, b) =>
                                                                  a + b) >
                                                          1
                                                      ? Text(" Participants",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .message
                                                                    .sentByMe!
                                                                ? CupertinoColors
                                                                    .white
                                                                : CupertinoColors
                                                                    .black,
                                                          ))
                                                      : Text(" Participant",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: widget
                                                                    .message
                                                                    .sentByMe!
                                                                ? CupertinoColors
                                                                    .white
                                                                : CupertinoColors
                                                                    .black,
                                                          )),
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: widget.message.sentByMe! ? 7 : 10,
                  right: widget.message.sentByMe! ? 2 : null,
                  left: widget.message.isGroupMessage
                      ? widget.message.sentByMe!
                          ? 20
                          : MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? 190
                              : MediaQuery.of(context).size.width / 2 - 3
                      : widget.message.sentByMe!
                          ? 20
                          : MediaQuery.of(context).size.width >
                                  Constants.limitWidth
                              ? 150
                              : MediaQuery.of(context).size.width / 2 - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateUtil.getFormattedTime(
                            context: context,
                            time: widget.message.time.microsecondsSinceEpoch
                                .toString()),
                        style: TextStyle(
                          color: widget.message.sentByMe!
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(width: 8),
                      MessageUtils.buildReadByIcon(
                        widget.message,
                        databaseService,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => Shimmer.fromColors(
            baseColor: CupertinoTheme.of(context).primaryContrastingColor,
            highlightColor: CupertinoTheme.of(context)
                .primaryContrastingColor
                .withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: widget.message.sentByMe!
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: widget.message.sentByMe!
                      ? const EdgeInsets.only(left: 30)
                      : const EdgeInsets.only(right: 30),
                  height: 75,
                  width: 200,
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryContrastingColor,
                    borderRadius: widget.message.sentByMe!
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                  ),
                ),
              ),
            )),
        error: (error, stack) => EventDeletedMessageTile(
              message: widget.message,
              databaseService: databaseService,
            ));
  }
}
