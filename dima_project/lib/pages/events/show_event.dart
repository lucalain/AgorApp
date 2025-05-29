import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ShowEvent extends ConsumerStatefulWidget {
  final String eventId;
  final UserData userData;
  final bool createdEvents;
  const ShowEvent({
    super.key,
    required this.eventId,
    required this.userData,
    required this.createdEvents,
  });

  @override
  ShowEventState createState() => ShowEventState();
}

class ShowEventState extends ConsumerState<ShowEvent> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    ref.read(joinedEventsProvider(widget.userData.uid!));
    ref.read(createdEventsProvider(widget.userData.uid!));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.createdEvents
        ? ref.watch(createdEventsProvider(widget.userData.uid!))
        : ref.watch(joinedEventsProvider(widget.userData.uid!));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      child: events.when(
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Image.asset(
                            'assets/darkMode/no_events.png',
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Image.asset(
                            'assets/images/no_events.png',
                          ),
                        ),
                  const Text('No events found',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            );
          }
          final int initialPage =
              events.indexWhere((event) => event.id == widget.eventId);
          _pageController = PageController(initialPage: initialPage);
          return PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CreateImageUtils.getUserImage(
                                widget.userData.imagePath!, 0),
                            const SizedBox(width: 10.0),
                            Text(
                              widget.userData.username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 400,
                              height: 400,
                              color: CupertinoColors.white,
                              child: (event.imagePath != null &&
                                      event.imagePath!.isNotEmpty)
                                  ? Image.network(
                                      event.imagePath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/default_event_image.png',
                                      fit: BoxFit.scaleDown,
                                    ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 370),
                              width: 400,
                              child: CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                borderRadius: BorderRadius.zero,
                                onPressed: () {
                                  ref.invalidate(eventProvider(event.id!));

                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EventPage(
                                        eventId: event.id!,
                                        imagePicker: ImagePicker(),
                                        eventService: EventService(),
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Go to Event',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 18,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(CupertinoIcons.forward,
                                        color: CupertinoColors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          event.name,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 18,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: event.details!.length,
                          itemBuilder: (context, index) {
                            return event.details![index].members!
                                    .contains(widget.userData.uid)
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 20.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.calendar,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                          ),
                                          const SizedBox(width: 10.0),
                                          Text(
                                            DateFormat('d/M/y').format(event
                                                .details![index].startDate!),
                                            style: TextStyle(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .textTheme
                                                        .textStyle
                                                        .color),
                                          ),
                                          const Text(' - '),
                                          Text(
                                            DateFormat('d/M/y').format(
                                                event.details![index].endDate!),
                                            style: TextStyle(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .textTheme
                                                        .textStyle
                                                        .color),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        children: [
                                          Icon(
                                            CupertinoIcons.map_pin_ellipse,
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                          ),
                                          const SizedBox(width: 10.0),
                                          Container(
                                            constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                            ),
                                            child: Text(
                                              event.details![index].location!,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (error, stackTrace) {
          return const Center(
            child: Text('Error occurred'),
          );
        },
      ),
    );
  }
}
