import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:dima_project/widgets/events/event_info_widget.dart';
import 'package:dima_project/pages/events/location_page.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class EditEventPage extends ConsumerStatefulWidget {
  final Event event;
  final ImagePicker imagePicker;
  final EventService eventService;
  final NotificationService notificationService;
  @override
  const EditEventPage(
      {super.key,
      required this.event,
      required this.imagePicker,
      required this.notificationService,
      required this.eventService});
  @override
  EditEventPageState createState() => EditEventPageState();
}

class EditEventPageState extends ConsumerState<EditEventPage> {
  Uint8List? selectedImagePath;
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  bool isPublic = true;

  Map<int, bool> map = {};
  Map<int, EventDetails> details = {};
  int numInfos = 1;
  String? defaultImage;
  final String uid = AuthService.uid;
  late final Event oldEvent;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _eventNameController.text = widget.event.name;
    _eventDescriptionController.text = widget.event.description;
    isPublic = widget.event.isPublic;
    for (int i = 0; i < widget.event.details!.length; i++) {
      details[i] = widget.event.details![i];
      map[i] = false;
    }
    numInfos = widget.event.details!.length;
    oldEvent = widget.event;
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.read(databaseServiceProvider);
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
        trailing: CupertinoButton(
            padding: const EdgeInsets.all(0),
            onPressed: () async {
              if (EventService.validateForm(
                  context,
                  _eventNameController.text,
                  _eventDescriptionController.text,
                  details.values.toList(),
                  widget.event.details!)) {
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

                await updateEvent(databaseService);
                if (_eventNameController.text != oldEvent.name ||
                    _eventDescriptionController.text != oldEvent.description ||
                    details.values.toList() != oldEvent.details! ||
                    selectedImagePath != null ||
                    isPublic != oldEvent.isPublic) {
                  await widget.notificationService.sendEventNotification(
                      widget.event.name, widget.event.id!, false, "1");
                }

                // Pop the loading dialog
                if (buildContext.mounted) {
                  Navigator.of(buildContext).pop();
                }

                // Navigate back if the context is still mounted
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: Text(
              'Done',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            )),
        middle: Text(
          'Edit Event',
          style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor, fontSize: 18),
        ),
      ),
      child: ListView(physics: const BouncingScrollPhysics(), children: [
        SafeArea(
            child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Stack(children: [
              ButtonImageWidget(
                defaultImage: defaultImage ?? widget.event.imagePath!,
                imageType: 2,
                imagePath: selectedImagePath,
                imagePicker: widget.imagePicker,
                imageInsertPageKey: (Uint8List selectedImagePath) {
                  setState(() {
                    this.selectedImagePath = selectedImagePath;
                    defaultImage = '';
                  });
                },
                child: selectedImagePath == null
                    ? ClipOval(
                        child: Container(
                          width: 100,
                          height: 100,
                          color: CupertinoTheme.of(context)
                              .primaryColor
                              .withOpacity(0.2),
                          child: widget.event.imagePath != ''
                              ? Image.network(
                                  widget.event.imagePath!,
                                  fit: BoxFit.cover,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Icon(
                                    CupertinoIcons.camera_fill,
                                    size: 40,
                                    color: CupertinoTheme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5),
                                  ),
                                ),
                        ),
                      )
                    : CreateImageUtils.getEventImageMemory(
                        selectedImagePath!, context,
                        small: false),
              ),
            ]),
            const SizedBox(height: 20),
            CupertinoTextField(
              focusNode: _nameFocus,
              onTapOutside: (event) => _nameFocus.unfocus(),
              placeholder: widget.event.name,
              controller: _eventNameController,
              padding: const EdgeInsets.all(16),
              maxLines: 3,
              minLines: 1,
              suffix: CupertinoButton(
                onPressed: () => _eventNameController.clear(),
                child: const Icon(CupertinoIcons.clear_circled_solid),
              ),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryContrastingColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            CupertinoTextField(
              focusNode: _descriptionFocus,
              onTapOutside: (event) => _descriptionFocus.unfocus(),
              placeholder: widget.event.description,
              controller: _eventDescriptionController,
              padding: const EdgeInsets.all(16),
              maxLines: 3,
              minLines: 1,
              suffix: CupertinoButton(
                onPressed: () => _eventDescriptionController.clear(),
                child: const Icon(CupertinoIcons.clear_circled_solid),
              ),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryContrastingColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 10),
            Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
                child: CupertinoListTile(
                  leading: isPublic
                      ? const Icon(CupertinoIcons.lock_open_fill)
                      : const Icon(CupertinoIcons.lock_fill),
                  title: const Text('Public Event'),
                  trailing: CupertinoSwitch(
                    value: isPublic,
                    onChanged: (bool value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                  ),
                )),
            const SizedBox(height: 20),
            ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numInfos,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  map.putIfAbsent(index, () => true);
                  details.putIfAbsent(index, () => EventDetails());

                  return EventInfoWidget(
                    fixedIndex: widget.event.details!.length,
                    location: () => _selectLocation(context, index),
                    startDate: (DateTime selectedDate, int index) {
                      setState(() {
                        details[index]!.startDate = selectedDate;
                      });
                    },
                    endDate: (DateTime selectedDate, int index) {
                      setState(() {
                        details[index]!.endDate = selectedDate;
                      });
                    },
                    startTime: (DateTime selectedTime, int index) {
                      setState(() {
                        details[index]!.startTime = selectedTime;
                      });
                    },
                    endTime: (DateTime selectedTime, int index) {
                      setState(() {
                        details[index]!.endTime = selectedTime;
                      });
                    },
                    add: () {
                      setState(() {
                        numInfos++;
                      });
                    },
                    numInfos: numInfos,
                    index: index,
                    detailsList: details,
                    boolMap: map,
                    onTap: () {
                      setState(() {
                        map[index] = !map[index]!;
                      });
                    },
                    delete: (int index) {
                      setState(() {
                        delete(index);
                      });
                    },
                  );
                }),
            if (widget.event.details!.length == numInfos)
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CupertinoButton(
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar_badge_plus,
                            color: CupertinoTheme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 5),
                          Text('Add more dates',
                              style: TextStyle(
                                  color:
                                      CupertinoTheme.of(context).primaryColor)),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          numInfos++;
                        });
                      }),
                ],
              ),
          ]),
        )),
      ]),
    );
  }

  Future<void> _selectLocation(BuildContext context, int idx) async {
    final result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => LocationPage(
          initialLocation: details[idx]!.latlng,
          eventService: widget.eventService,
        ),
      ),
    );

    if (result != null && result is LatLng) {
      setState(() {
        details[idx]!.latlng = result;
      });
      var loc = await widget.eventService.getAddressFromLatLng(result);
      setState(() {
        details[idx]!.location = loc!;
      });
    }
  }

  Future<void> updateEvent(DatabaseService databaseService) async {
    debugPrint("Updating event");

    for (int i = 0; i < details.length; i++) {
      details[i]!.members = [uid];
    }

    final event = Event(
      id: widget.event.id,
      admin: widget.event.admin,
      name: _eventNameController.text,
      description: _eventDescriptionController.text,
      isPublic: isPublic,
      imagePath: widget.event.imagePath,
      details: details.values.toList(),
      createdAt: widget.event.createdAt,
    );
    await databaseService.updateEvent(
      event,
      selectedImagePath,
      selectedImagePath == null,
      widget.event.isPublic != isPublic,
    );
    ref.invalidate(eventProvider(widget.event.id!));
    ref.invalidate(createdEventsProvider(uid));
  }

  void delete(int index) {
    setState(() {
      if (index == numInfos - 1) {
        map.remove(index);
        details.remove(index);
      } else {
        for (int i = numInfos - 1; i > index; i--) {
          map[i - 1] = map[i]!;
          details[i - 1] = details[i]!;
        }
        details.remove(numInfos - 1);
        map.remove(numInfos - 1);
      }
      numInfos--;
    });
  }
}
