import 'dart:typed_data';

import 'package:dima_project/models/event.dart';
import 'package:dima_project/pages/events/share_event_followers_page.dart';
import 'package:dima_project/pages/events/share_event_groups_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/events/event_info_widget.dart';
import 'package:dima_project/pages/events/location_page.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:dima_project/services/notification_service.dart';

class CreateEventPage extends ConsumerStatefulWidget {
  final String? groupId;
  final bool canNavigate;
  final Function? navigateToPage;
  final ImagePicker imagePicker;
  final EventService eventService;
  const CreateEventPage({
    super.key,
    this.groupId,
    required this.canNavigate,
    this.navigateToPage,
    required this.imagePicker,
    required this.eventService,
  });

  @override
  CreateEventPageState createState() => CreateEventPageState();
}

class CreateEventPageState extends ConsumerState<CreateEventPage>
    with TickerProviderStateMixin {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ButtonImageWidgetState>();
  late AnimationController animationController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  DateTime now = DateTime.now();
  bool isPublic = true;
  List<String> uids = [];
  List<String> groupIds = [];
  int numInfos = 1;
  Map<int, bool> map = {};
  Map<int, EventDetails> details = {};
  late final DatabaseService databaseService;
  late final NotificationService notificationService;
  final String uid = AuthService.uid;

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    animationController.dispose();
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  void initState() {
    setState(() {
      if (widget.groupId != null) groupIds.add(widget.groupId!);
    });

    animationController = AnimationController(
      vsync: this,
    );
    databaseService = ref.read(databaseServiceProvider);
    notificationService = ref.read(notificationServiceProvider);

    super.initState();
  }

  Future<void> _createEvent(DatabaseService databaseService) async {
    if (EventService.validateForm(
      context,
      _eventNameController.text,
      _eventDescriptionController.text,
      details.values.toList(),
      null,
    )) {
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
      for (int i = 0; i < details.length; i++) {
        details[i]!.members = [uid];
      }
      final event = Event(
        name: _eventNameController.text,
        admin: uid,
        description: _eventDescriptionController.text,
        isPublic: isPublic,
        imagePath: selectedImagePath.isNotEmpty ? '' : null,
        details: details.values.toList(),
      );

      await databaseService.createEvent(
          event, selectedImagePath, uids, groupIds);
      ref.invalidate(createdEventsProvider(uid));
      if (!buildContext.mounted) return;
      Navigator.of(buildContext).pop();

      showDoneDialog(databaseService);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        trailing: CupertinoButton(
          onPressed: () async {
            await _createEvent(databaseService);
          },
          padding: const EdgeInsets.all(0),
          child: Text(
            'Done',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > Constants.limitWidth
                  ? 20
                  : 15,
              color: CupertinoTheme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupChatPage(
                storageService: StorageService(),
                canNavigate: widget.canNavigate,
                groupId: widget.groupId!,
                navigateToPage: widget.navigateToPage,
                databaseService: databaseService,
                notificationService: notificationService,
                imagePicker: ImagePicker(),
                eventService: widget.eventService,
              ));
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        middle: Text(
          'Create Event',
          style: TextStyle(
              fontSize: 25, color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(children: [
                              ButtonImageWidget(
                                defaultImage: '',
                                imageType: 2,
                                imagePath: selectedImagePath,
                                imagePicker: widget.imagePicker,
                                imageInsertPageKey:
                                    (Uint8List selectedImagePath) {
                                  setState(() {
                                    this.selectedImagePath = selectedImagePath;
                                  });
                                },
                                child: CreateImageUtils.getEventImageMemory(
                                  selectedImagePath,
                                  context,
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(
                            width: widget.canNavigate
                                ? MediaQuery.of(context).size.width * 0.6 - 92
                                : (MediaQuery.of(context).size.width >
                                        Constants.limitWidth)
                                    ? MediaQuery.of(context).size.width - 92
                                    : MediaQuery.of(context).size.width * 0.75,
                            child: CupertinoTextField(
                              controller: _eventNameController,
                              onTap: () => _nameFocus.requestFocus(),
                              focusNode: _nameFocus,
                              onTapOutside: (PointerDownEvent event) =>
                                  _nameFocus.unfocus(),
                              textInputAction: TextInputAction.next,
                              padding: const EdgeInsets.all(16),
                              placeholder: 'Event Name',
                              minLines: 1,
                              maxLines: 3,
                              suffix: CupertinoButton(
                                onPressed: () => _eventNameController.clear(),
                                child: const Icon(
                                    CupertinoIcons.clear_circled_solid),
                              ),
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width >
                              Constants.limitWidth)
                          ? MediaQuery.of(context).size.width - 16
                          : MediaQuery.of(context).size.width * 0.75 + 76,
                      child: CupertinoTextField(
                        onTap: () => _descriptionFocus.requestFocus(),
                        focusNode: _descriptionFocus,
                        onTapOutside: (PointerDownEvent event) =>
                            _descriptionFocus.unfocus(),
                        controller: _eventDescriptionController,
                        padding: const EdgeInsets.all(16),
                        placeholder: 'Event Description',
                        maxLines: 3,
                        minLines: 1,
                        suffix: CupertinoButton(
                          onPressed: () => _eventDescriptionController.clear(),
                          child: const Icon(CupertinoIcons.clear_circled_solid),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    ListView.builder(
                        itemCount: numInfos,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          map.putIfAbsent(index, () => true);
                          details.putIfAbsent(index, () => EventDetails());

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: EventInfoWidget(
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
                              fixedIndex: 0,
                            ),
                          );
                        }),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                      ),
                      child: Column(
                        children: [
                          CupertinoListTile(
                            title: const Row(
                              children: [
                                Icon(CupertinoIcons.person_3_fill),
                                SizedBox(width: 10),
                                Text('Share with Followers'),
                              ],
                            ),
                            trailing: const Icon(CupertinoIcons.forward),
                            onTap: () async {
                              final List<String>? users = await Navigator.of(
                                      context,
                                      rootNavigator: true)
                                  .push(
                                CupertinoPageRoute(
                                  builder: (context) => ShareEventFollowersPage(
                                    invitedUsers: uids,
                                  ),
                                ),
                              );
                              if (users != null) {
                                setState(() {
                                  uids = users;
                                });
                              }
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          CupertinoListTile(
                            title: const Row(
                              children: [
                                Icon(CupertinoIcons.person_2_square_stack),
                                SizedBox(width: 10),
                                Text('Share with Groups'),
                              ],
                            ),
                            trailing: const Icon(CupertinoIcons.forward),
                            onTap: () async {
                              final List<String>? groups = await Navigator.of(
                                      context,
                                      rootNavigator: true)
                                  .push(
                                CupertinoPageRoute(
                                  builder: (context) => ShareEventsGroupPage(
                                    groupIds: groupIds,
                                    databaseService: databaseService,
                                  ),
                                ),
                              );
                              if (groups != null) {
                                setState(() {
                                  groupIds = groups;
                                });
                              }
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          CupertinoListTile(
                            title: Row(
                              children: [
                                isPublic
                                    ? const Icon(CupertinoIcons.lock_open_fill)
                                    : const Icon(CupertinoIcons.lock_fill),
                                const SizedBox(width: 10),
                                const Text('Public Event'),
                              ],
                            ),
                            trailing: Transform.scale(
                              scale: 0.75,
                              child: CupertinoSwitch(
                                value: isPublic,
                                onChanged: (bool value) {
                                  setState(() {
                                    isPublic = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showDoneDialog(DatabaseService databaseService) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext newContext) {
        return CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'assets/animations/done.json',
                repeat: true,
                controller: animationController,
                onLoaded: (composition) {
                  animationController.duration = composition.duration;
                  animationController.forward();
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Event created successfully!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CupertinoButton(
                child: const Text('Ok'),
                onPressed: () {
                  animationController.reset();

                  Navigator.of(newContext).pop();

                  if (mounted) {
                    setState(() {
                      _eventNameController.clear();
                      _eventDescriptionController.clear();
                      selectedImagePath = Uint8List(0);
                      isPublic = true;
                      uids = [];
                      groupIds = [];
                      numInfos = 1;
                      map = {};
                      details = {};
                    });
                  }
                  if (widget.canNavigate) {
                    widget.navigateToPage!(GroupChatPage(
                      storageService: StorageService(),
                      canNavigate: widget.canNavigate,
                      groupId: widget.groupId!,
                      navigateToPage: widget.navigateToPage,
                      databaseService: databaseService,
                      notificationService: notificationService,
                      imagePicker: ImagePicker(),
                      eventService: widget.eventService,
                    ));
                  } else {
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
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
