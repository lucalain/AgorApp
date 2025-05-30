import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/event.dart' as event_model;
import 'package:dima_project/pages/events/event_requests_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/pages/events/show_event_members_page.dart';
import 'package:dima_project/widgets/events/show_date_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:shimmer/shimmer.dart';

class DetailEventPage extends ConsumerStatefulWidget {
  final String eventId;
  final String detailId;

  const DetailEventPage({
    super.key,
    required this.eventId,
    required this.detailId,
  });
  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends ConsumerState<DetailEventPage> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(eventProvider(widget.eventId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    final NotificationService notificationService =
        ref.watch(notificationServiceProvider);
    final event = ref.watch(eventProvider(widget.eventId));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          automaticallyImplyLeading: false,
          transitionBetweenRoutes: false,
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: event.when(
            data: (event) {
              return Text(event.name,
                  style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor));
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) {
              return const SizedBox.shrink();
            },
          ),
          leading: CupertinoNavigationBarBackButton(
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              ref.invalidate(joinedEventsProvider(uid));
              ref.invalidate(createdEventsProvider(uid));
              ref.invalidate(eventProvider(widget.eventId));
              Navigator.of(context).pop();
            },
          )),
      child: event.when(data: (event) {
        event_model.EventDetails detail = event_model.EventDetails(
          id: '',
          location: '',
          startDate: DateTime.now(),
          startTime: DateTime.now(),
          endDate: DateTime.now(),
          endTime: DateTime.now(),
          latlng: const LatLng(0, 0),
          members: [],
          requests: [],
        );
        try {
          detail = event.details!.firstWhere(
            (element) => element.id == widget.detailId,
            orElse: () => throw Exception('Detail not found'),
          );
        } catch (e) {
          const SizedBox.shrink();
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShowDateWidget(
                      date: detail.startDate!, time: detail.startTime!),
                  const Text(
                    ' - ',
                  ),
                  ShowDateWidget(date: detail.endDate!, time: detail.endTime!)
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LineAwesomeIcons.map_pin_solid,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.9,
                    ),
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      'Location: ${detail.location}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width * 0.9,
                child: FlutterMap(
                    options: MapOptions(
                      onTap: (TapPosition position, LatLng latlng) async {
                        final coords = Coords(
                            detail.latlng!.latitude, detail.latlng!.longitude);
                        final title = event.name;
                        final availableMaps = await MapLauncher.installedMaps;
                        if (context.mounted) {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext newContext) {
                              return CupertinoActionSheet(
                                actions: [
                                  for (var map in availableMaps)
                                    CupertinoActionSheetAction(
                                      onPressed: () => map.showMarker(
                                        coords: coords,
                                        title: title,
                                      ),
                                      child: Row(
                                        children: [
                                          SvgPicture.asset(
                                            map.icon,
                                            height: 30.0,
                                            width: 30.0,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(map.mapName),
                                        ],
                                      ),
                                    )
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () => Navigator.pop(newContext),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                        color: CupertinoColors.systemRed),
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                      initialCenter: detail.latlng!,
                      initialZoom: 11,
                      interactionOptions:
                          const InteractionOptions(flags: InteractiveFlag.none),
                    ),
                    children: [
                      openStreetMapTileLayer,
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: detail.latlng!,
                            child: Icon(
                              CupertinoIcons.location_solid,
                              color: CupertinoTheme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ]),
              ),
              const SizedBox(height: 30),
              Text(
                detail.members!.length.toString(),
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => ShowEventMembersPage(
                        eventId: widget.eventId,
                        detailId: widget.detailId,
                        admin: event.admin,
                      ),
                    ),
                  );
                },
                child: Text(
                  detail.members!.length > 1 ? "Participants" : "Participant",
                  style: CupertinoTheme.of(context)
                      .textTheme
                      .textStyle
                      .copyWith(
                          color: CupertinoColors.systemGrey,
                          fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              if (event.admin != uid &&
                  DateTime.now().isBefore(DateTime(
                    detail.startDate!.year,
                    detail.startDate!.month,
                    detail.startDate!.day,
                    detail.startTime!.hour,
                    detail.startTime!.minute,
                  )))
                CupertinoButton.filled(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  onPressed: () async {
                    try {
                      if (!DateTime.now().isBefore(DateTime(
                        detail.startDate!.year,
                        detail.startDate!.month,
                        detail.startDate!.day,
                        detail.startTime!.hour,
                        detail.startTime!.minute,
                      ))) {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext newContext) {
                            return CupertinoAlertDialog(
                              title: const Text('Event in progress'),
                              content: const Text('Event has already started.'),
                              actions: <Widget>[
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    ref.invalidate(eventProvider(event.id!));
                                    ref.invalidate(joinedEventsProvider(uid));
                                    ref.invalidate(createdEventsProvider(uid));
                                    Navigator.of(newContext).pop();
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                        return;
                      }
                      debugPrint('Joining event');
                      await databaseService.toggleEventJoin(
                        event.id!,
                        detail.id!,
                      );
                      ref.invalidate(eventProvider(event.id!));
                      ref.invalidate(joinedEventsProvider(uid));
                    } on Exception catch (e) {
                      debugPrint(e.toString());
                      final String message =
                          e.toString().split(':')[1].substring(1);
                      debugPrint(message);
                      if (!context.mounted) return;
                      showCupertinoDialog(
                        context: context,
                        builder: (BuildContext newContext) {
                          return CupertinoAlertDialog(
                            title: const Text('Error'),
                            content: Text(message),
                            actions: <Widget>[
                              CupertinoDialogAction(
                                child: const Text('Ok'),
                                onPressed: () {
                                  ref.invalidate(eventProvider(event.id!));
                                  ref.invalidate(joinedEventsProvider(uid));
                                  ref.invalidate(createdEventsProvider(uid));
                                  Navigator.of(newContext).pop();

                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    detail.members!.contains(uid)
                        ? "Unsubscribe"
                        : detail.requests!.contains(uid)
                            ? "Requested"
                            : "Subscribe",
                    style: const TextStyle(
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                CupertinoButton(
                  onPressed: () async {
                    debugPrint('Adding event to calendar');
                    Add2Calendar.addEvent2Cal(Event(
                      title: event.name,
                      description: event.description,
                      location: detail.location,
                      startDate: DateTime(
                          detail.startDate!.year,
                          detail.startDate!.month,
                          detail.startDate!.day,
                          detail.startTime!.hour,
                          detail.startTime!.minute),
                      endDate: DateTime(
                          detail.endDate!.year,
                          detail.endDate!.month,
                          detail.endDate!.day,
                          detail.endTime!.hour,
                          detail.endTime!.minute),
                      iosParams: const IOSParams(
                        reminder: Duration(hours: 1),
                      ),
                    ));
                  },
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.calendar_badge_plus,
                          color: CupertinoTheme.of(context).primaryColor),
                      const SizedBox(width: 5),
                      Text('Add to calendar',
                          style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                event.admin == uid
                    ? Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor,
                        ),
                        child: event.isPublic == false
                            ? Column(
                                children: [
                                  CupertinoListTile(
                                    trailing: Row(
                                      children: [
                                        detail.requests!.isNotEmpty
                                            ? Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor,
                                                ),
                                                child: Text(
                                                  detail.requests!.length
                                                      .toString(),
                                                  style: const TextStyle(
                                                    color:
                                                        CupertinoColors.white,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        const SizedBox(width: 10),
                                        const Icon(CupertinoIcons.forward),
                                      ],
                                    ),
                                    title: const Row(children: [
                                      Icon(CupertinoIcons.square_list),
                                      SizedBox(width: 10),
                                      Text('Requests'),
                                    ]),
                                    onTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              EventRequestsPage(
                                            eventId: widget.eventId,
                                            detailId: widget.detailId,
                                            requests: detail.requests!,
                                            databaseService: databaseService,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Container(
                                    height: 1,
                                    color: CupertinoColors.opaqueSeparator
                                        .withOpacity(0.2),
                                  ),
                                  CupertinoListTile(
                                    trailing:
                                        const Icon(CupertinoIcons.forward),
                                    title: const Row(children: [
                                      Icon(CupertinoIcons.trash),
                                      SizedBox(width: 10),
                                      Text('Delete'),
                                    ]),
                                    onTap: () async {
                                      // Show confirmation dialog
                                      showCupertinoDialog(
                                        context: context,
                                        builder: (newContext) =>
                                            CupertinoAlertDialog(
                                          title:
                                              const Text('Date cancellation'),
                                          content: const Text(
                                              'Are you sure you want to delete this date?'),
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
                                                await delete(
                                                    newContext,
                                                    databaseService,
                                                    notificationService,
                                                    event);
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              )
                            : CupertinoListTile(
                                trailing: const Icon(CupertinoIcons.forward),
                                title: const Row(children: [
                                  Icon(CupertinoIcons.trash),
                                  SizedBox(width: 10),
                                  Text('Delete'),
                                ]),
                                onTap: () async {
                                  // Show confirmation dialog
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (newContext) =>
                                        CupertinoAlertDialog(
                                      title: const Text('Date cancellation'),
                                      content: const Text(
                                          'Are you sure you want to delete this date?'),
                                      actions: <Widget>[
                                        CupertinoDialogAction(
                                          child: const Text('No'),
                                          onPressed: () =>
                                              Navigator.of(newContext).pop(),
                                        ),
                                        CupertinoDialogAction(
                                            child: const Text('Yes'),
                                            onPressed: () async {
                                              await delete(
                                                  newContext,
                                                  databaseService,
                                                  notificationService,
                                                  event);
                                            }),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      )
                    : Container(),
              ]),
            ],
          ),
        );
      }, loading: () {
        return Shimmer.fromColors(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 100,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 100,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor,
                                  borderRadius: BorderRadius.circular(10)),
                              height: 100,
                            ),
                          ],
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
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: CupertinoTheme.of(context)
                                  .primaryContrastingColor,
                              borderRadius: BorderRadius.circular(10)),
                          height: 200,
                          width: MediaQuery.of(context).size.width * 0.9,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }, error: (error, stackTrace) {
        return Center(
          child: Text('Error: $error'),
        );
      }),
    );
  }

  Future<void> delete(BuildContext newContext, DatabaseService databaseService,
      NotificationService notificationService, event) async {
    Navigator.of(newContext).pop();
    BuildContext buildContext = context;
    // Show the loading dialog
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext newContext) {
        buildContext = newContext;
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await notificationService.sendEventNotification(
        event.name, event.id!, true, widget.detailId);
    await databaseService.deleteDetail(event.id!, widget.detailId);

    ref.invalidate(eventProvider(event.id!));
    ref.invalidate(createdEventsProvider(uid));

    if (buildContext.mounted) {
      Navigator.of(buildContext).pop();
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'polimi.dima_project.agorapp',
      errorImage: CachedNetworkImageProvider(
          'https://www.openstreetmap.org/404.png',
          errorListener: (Object error) {}));
}
