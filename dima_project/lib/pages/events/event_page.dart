import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/pages/events/share_event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/utils/create_image_utils.dart';

import 'package:dima_project/pages/events/edit_event_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class EventPage extends ConsumerStatefulWidget {
  final String eventId;
  final ImagePicker imagePicker;
  final EventService eventService;
  const EventPage({
    super.key,
    required this.eventId,
    required this.imagePicker,
    required this.eventService,
  });

  @override
  EventPageState createState() => EventPageState();
}

class EventPageState extends ConsumerState<EventPage> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(eventProvider(widget.eventId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = ref.read(databaseServiceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final event = ref.watch(eventProvider(widget.eventId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => ShareEventPage(
                  databaseService: databaseService,
                  eventId: widget.eventId,
                ),
              ),
            );
          },
          child: const Icon(
            CupertinoIcons.share,
          ),
        ),
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: Text(
          'Event',
          style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor, fontSize: 18),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: event.when(
                data: (event) {
                  return SafeArea(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CreateImageUtils.getEventImage(
                              event.imagePath!, context),
                          const SizedBox(height: 10),
                          Text(
                            textAlign: TextAlign.start,
                            event.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    event.description,
                                    maxLines: 5,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )),
                          const SizedBox(height: 20),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: event.details!.length,
                            itemBuilder: (BuildContext context, int index) {
                              final detail = event.details![index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: CupertinoTheme.of(context)
                                          .primaryContrastingColor,
                                    ),
                                    child: CupertinoListTile(
                                      leading: Icon(
                                        CupertinoIcons.calendar,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                          ),
                                          Text(
                                            detail.location!,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: DateTime(
                                                  detail.startDate!.year,
                                                  detail.startDate!.month,
                                                  detail.startDate!.day,
                                                  detail.startTime!.hour,
                                                  detail.startTime!.minute)
                                              .isBefore(DateTime.now())
                                          ? const Icon(
                                              CupertinoIcons.circle_fill,
                                              color: CupertinoColors.systemRed)
                                          : const Icon(
                                              CupertinoIcons.circle_fill,
                                              color:
                                                  CupertinoColors.systemGreen),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                DetailEventPage(
                                              eventId: event.id!,
                                              detailId: detail.id!,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              );
                            },
                          ),
                          uid == event.admin
                              ? Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CupertinoTheme.of(context)
                                        .primaryContrastingColor,
                                  ),
                                  child: Column(
                                    children: [
                                      CupertinoListTile(
                                        trailing:
                                            const Icon(CupertinoIcons.forward),
                                        title: const Row(children: [
                                          Icon(CupertinoIcons.pencil),
                                          SizedBox(width: 10),
                                          Text('Edit Event'),
                                        ]),
                                        onTap: () {
                                          ref.invalidate(
                                              eventProvider(widget.eventId));
                                          ref.invalidate(
                                              createdEventsProvider(uid));
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (context) =>
                                                      EditEventPage(
                                                        event: event,
                                                        imagePicker:
                                                            widget.imagePicker,
                                                        eventService:
                                                            widget.eventService,
                                                        notificationService:
                                                            notificationService,
                                                      )));
                                        },
                                      ),
                                      Container(
                                        height: 1,
                                        color: CupertinoColors.opaqueSeparator
                                            .withOpacity(0.2),
                                      ),
                                      CupertinoListTile(
                                          trailing: const Icon(
                                              CupertinoIcons.forward),
                                          title: const Row(
                                            children: [
                                              Icon(CupertinoIcons.trash),
                                              SizedBox(width: 10),
                                              Text(
                                                'Delete Event',
                                              ),
                                            ],
                                          ),
                                          onTap: () {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (newContext) =>
                                                  CupertinoAlertDialog(
                                                title:
                                                    const Text('Delete Event'),
                                                content: const Text(
                                                    'Are you sure you want to delete this event?'),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: const Text('No'),
                                                    onPressed: () =>
                                                        Navigator.of(newContext)
                                                            .pop(),
                                                  ),
                                                  CupertinoDialogAction(
                                                    child: const Text('Yes'),
                                                    onPressed: () async {
                                                      Navigator.of(newContext)
                                                          .pop();
                                                      BuildContext
                                                          buildContext =
                                                          context;
                                                      // Show the loading dialog
                                                      showCupertinoDialog(
                                                        context: context,
                                                        barrierDismissible:
                                                            false,
                                                        builder: (BuildContext
                                                            newContext) {
                                                          buildContext =
                                                              newContext;
                                                          return const CupertinoAlertDialog(
                                                            content:
                                                                CupertinoActivityIndicator(),
                                                          );
                                                        },
                                                      );

                                                      try {
                                                        await notificationService
                                                            .sendEventNotification(
                                                                event.name,
                                                                widget.eventId,
                                                                false,
                                                                "2");
                                                      } catch (e) {
                                                        debugPrint(
                                                            e.toString());
                                                      }
                                                      await databaseService
                                                          .deleteEvent(
                                                              widget.eventId);
                                                      ref.invalidate(
                                                          createdEventsProvider(
                                                              uid));
                                                      ref.invalidate(
                                                          eventProvider(
                                                              widget.eventId));
                                                      if (buildContext
                                                          .mounted) {
                                                        Navigator.of(
                                                                buildContext)
                                                            .pop();
                                                      }
                                                      if (context.mounted) {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => Shimmer.fromColors(
                  baseColor: CupertinoTheme.of(context).primaryContrastingColor,
                  highlightColor: CupertinoTheme.of(context)
                      .primaryContrastingColor
                      .withOpacity(0.5),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SafeArea(
                          child: Container(
                            padding: const EdgeInsets.all(30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: ClipOval(
                                    child: Container(
                                        width: 100,
                                        height: 100,
                                        color: CupertinoTheme.of(context)
                                            .primaryContrastingColor),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  width: 180,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: CupertinoTheme.of(context)
                                          .primaryContrastingColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 20,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: CupertinoTheme.of(context)
                                          .primaryContrastingColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  height: 100,
                                ),
                                const SizedBox(height: 20),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: 3,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: CupertinoTheme.of(context)
                                              .primaryContrastingColor,
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height: 50,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (error, stackTrace) {
                  return MediaQuery.of(context).size.width >
                          Constants.limitWidth
                      ? MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Container(
                              color: CupertinoTheme.of(context)
                                  .scaffoldBackgroundColor,
                              width: MediaQuery.of(context).size.width,
                              child: Image.asset(
                                'assets/darkMode/event_canceled_tablet.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              color: CupertinoTheme.of(context)
                                  .scaffoldBackgroundColor,
                              width: MediaQuery.of(context).size.width,
                              child: Image.asset(
                                  'assets/images/event_canceled_tablet.png',
                                  fit: BoxFit.cover),
                            )
                      : MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.75,
                              child: Image.asset(
                                  'assets/darkMode/event_canceled.png',
                                  fit: BoxFit.cover),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.75,
                              color: CupertinoTheme.of(context)
                                  .scaffoldBackgroundColor,
                              child: Image.asset(
                                  'assets/images/event_canceled.png',
                                  fit: BoxFit.cover),
                            );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
