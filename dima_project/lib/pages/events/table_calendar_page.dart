import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:dima_project/utils/table_calendar_util.dart';

class TableCalendarPage extends ConsumerStatefulWidget {
  final ImagePicker imagePicker;
  final EventService eventService;
  const TableCalendarPage(
      {super.key, required this.imagePicker, required this.eventService});

  @override
  TableCalendarPageState createState() => TableCalendarPageState();
}

class TableCalendarPageState extends ConsumerState<TableCalendarPage> {
  late ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<Event> joinedEvents = [];
  List<Event> createdEvents = [];
  @override
  void initState() {
    super.initState();
    ref.read(joinedEventsProvider(AuthService.uid));
    ref.read(createdEventsProvider(AuthService.uid));
    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(
      _selectedDay!,
    ));
  }

  @override
  void dispose() {
    _focusedDay.dispose();
    _selectedEvents.dispose();

    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime d) {
    List<Event> result = [];
    result.addAll(_getJoinedEventsForDay(d));
    result.addAll(_getCreatedEventsForDay(d));
    return result;
  }

  List<Event> _getJoinedEventsForDay(DateTime day) {
    List<Event> result = [];
    for (final event in joinedEvents) {
      List<EventDetails> details = [];
      for (final detail in event.details!) {
        if (!detail.members!.contains(AuthService.uid)) {
          continue;
        }

        DateTime start = DateTime(
          detail.startDate!.year,
          detail.startDate!.month,
          detail.startDate!.day,
        );
        DateTime end = DateTime(
            detail.endDate!.year, detail.endDate!.month, detail.endDate!.day);
        if (((day.isAfter(start) && day.isBefore(end)) ||
            isSameDay(start, day) ||
            isSameDay(end, day))) {
          details.add(detail);
        }
      }
      if (details.isNotEmpty) {
        Event e = event.copyWith(details: details);
        result.add(e);
      }
    }
    return result;
  }

  List<Event> _getCreatedEventsForDay(DateTime day) {
    List<Event> result = [];
    for (final event in createdEvents) {
      List<EventDetails> details = [];
      for (final detail in event.details!) {
        if (!detail.members!.contains(AuthService.uid)) {
          continue;
        }
        DateTime start = DateTime(
          detail.startDate!.year,
          detail.startDate!.month,
          detail.startDate!.day,
        );
        DateTime end = DateTime(
            detail.endDate!.year, detail.endDate!.month, detail.endDate!.day);
        if (((day.isAfter(start) && day.isBefore(end)) ||
            isSameDay(start, day) ||
            isSameDay(end, day))) {
          details.add(detail);
        }
      }
      if (details.isNotEmpty) {
        Event e = event.copyWith(details: details);
        result.add(e);
      }
    }
    return result;
  }

  List<Event> _getEventsForRange(
    DateTime start,
    DateTime end,
  ) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days)
        ..._getEventsForDay(
          d,
        ),
    ];
  }

  void _onDaySelected(
    DateTime selectedDay,
    DateTime focusedDay,
  ) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(
        selectedDay,
      );
    }
  }

  void _onRangeSelected(
    DateTime? start,
    DateTime? end,
    DateTime focusedDay,
  ) {
    setState(() {
      _selectedDay = null;
      _focusedDay.value = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  void _updateEvents(List<Event> newEvents, bool joined) {
    if (mounted) {
      setState(() {
        if (joined) {
          // Remove events that no longer exist

          joinedEvents.removeWhere((event) => !newEvents.contains(event));

          for (Event newEvent in newEvents) {
            final existingIndex =
                joinedEvents.indexWhere((event) => event.id == newEvent.id);
            if (existingIndex != -1) {
              joinedEvents[existingIndex] = newEvent;
            } else {
              joinedEvents.add(newEvent);
            }
          }
        } else {
          // Remove events that no longer exist
          createdEvents.removeWhere((event) => !newEvents.contains(event));
          for (Event newEvent in newEvents) {
            final existingIndex =
                createdEvents.indexWhere((event) => event.id == newEvent.id);
            if (existingIndex != -1) {
              createdEvents[existingIndex] = newEvent;
            } else {
              createdEvents.add(newEvent);
            }
          }
        }
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(joinedEventsProvider(AuthService.uid), (_, next) {
      if (next is AsyncData) _updateEvents(next.value!, true);
    });
    ref.listen(createdEventsProvider(AuthService.uid), (_, next) {
      if (next is AsyncData) _updateEvents(next.value!, false);
    });
    return _buildCalendar();
  }

  Widget _buildCalendar() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          'Calendar',
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontSize: 25,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CreateEventPage(
                  canNavigate: false,
                  imagePicker: widget.imagePicker,
                  eventService: widget.eventService,
                ),
              ),
            );
          },
          child: Icon(
            CupertinoIcons.add_circled,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
      ),
      child: Column(
        children: [
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay,
            builder: (context, value, _) {
              return TableCalendar<Event>(
                pageJumpingEnabled: true,
                calendarBuilders: const CalendarBuilders(),
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: value,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: _calendarFormat,
                rangeSelectionMode: _rangeSelectionMode,
                eventLoader: _getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  rangeStartDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeEndDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  rangeHighlightColor:
                      CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                  markerDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .color!
                        .withOpacity(1),
                    shape: BoxShape.circle,
                  ),
                  todayDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context)
                        .primaryColor
                        .withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                      color: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .color!),
                  outsideDaysVisible: false,
                  outsideTextStyle: TextStyle(
                    color: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .color!
                        .withOpacity(0.5),
                  ),
                ),
                onDaySelected: _onDaySelected,
                onRangeSelected: _onRangeSelected,
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay.value = focusedDay;
                },
              );
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return SizedBox(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 4),
                            child: Text(
                              event.name,
                              style: TextStyle(
                                fontSize: 20,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                              ),
                              height: event.details!.length * 45,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: event.details!.length,
                                itemBuilder: (context, index) {
                                  final detail = event.details![index];

                                  return Column(
                                    children: [
                                      CupertinoListTile(
                                        leading: Icon(
                                          CupertinoIcons.calendar,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                        ),
                                        title: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                Constants.limitWidth
                                            ? Row(
                                                children: [
                                                  Text(
                                                    '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    detail.location!,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                ],
                                              )
                                            : Column(
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
                                                  )
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
                                                color:
                                                    CupertinoColors.systemRed)
                                            : const Icon(
                                                CupertinoIcons.circle_fill,
                                                color: CupertinoColors
                                                    .systemGreen),
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
                                      if (index != event.details!.length - 1)
                                        Container(
                                          height: 1,
                                          color: CupertinoColors.separator,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
