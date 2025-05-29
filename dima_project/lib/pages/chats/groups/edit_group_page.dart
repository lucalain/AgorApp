import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/categories_page.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/utils/group_helper.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/groups/invite_user_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class EditGroupPage extends ConsumerStatefulWidget {
  final Group group;
  final bool canNavigate;
  final Function? navigateToPage;
  final ImagePicker imagePicker;
  @override
  const EditGroupPage({
    super.key,
    required this.group,
    required this.canNavigate,
    this.navigateToPage,
    required this.imagePicker,
  });
  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends ConsumerState<EditGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List? selectedImagePath;
  String? defaultImage;
  bool isPublic = true;
  List<String> uuids = [];
  List<String> selectedCategories = [];
  int index = 0;
  late final DatabaseService databaseService;
  late final NotificationService notificationService;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  @override
  void dispose() {
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    databaseService = ref.read(databaseServiceProvider);
    notificationService = ref.read(notificationServiceProvider);
    setState(() {
      isPublic = widget.group.isPublic;
      selectedCategories = widget.group.categories!;
      _groupNameController.text = widget.group.name;
      _groupDescriptionController.text = widget.group.description!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: index == 0
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(GroupInfoPage(
                      groupId: widget.group.id,
                      canNavigate: widget.canNavigate,
                      navigateToPage: widget.navigateToPage,
                      databaseService: databaseService,
                      notificationService: notificationService,
                      imagePicker: widget.imagePicker,
                    ));
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              )
            : CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  setState(() {
                    index = 0;
                  });
                },
              ),
        trailing: index == 0
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (index == 0) {
                    if (!GroupHelper.validateNameAndDescription(
                      context,
                      _groupNameController.text,
                      _groupDescriptionController.text,
                    )) {
                      return;
                    }
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
                    await updateGroup(databaseService);
                    ref.invalidate(groupsProvider(AuthService.uid));
                    ref.invalidate(groupProvider(widget.group.id));
                    if (buildContext.mounted) {
                      Navigator.of(buildContext).pop();
                    }

                    if (context.mounted) {
                      if (widget.canNavigate) {
                        widget.navigateToPage!(GroupInfoPage(
                            groupId: widget.group.id,
                            canNavigate: widget.canNavigate,
                            databaseService: databaseService,
                            notificationService: notificationService,
                            navigateToPage: widget.navigateToPage,
                            imagePicker: widget.imagePicker));
                      } else {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    }
                  }
                },
                child: Text(
                  'Done',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ))
            : null,
        middle: Text('Edit Group',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
      ),
      child: index == 0
          ? buildPage1(context)
          : SafeArea(
              child: CategoriesForm(
                selectedCategories: selectedCategories,
              ),
            ),
    );
  }

  Widget buildPage1(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(children: [
                ButtonImageWidget(
                  imageInsertPageKey: (Uint8List image) {
                    setState(() {
                      selectedImagePath = image;
                    });
                  },
                  imageType: 0,
                  defaultImage: widget.group.imagePath!,
                  imagePicker: widget.imagePicker,
                  child: selectedImagePath == null
                      ? ClipOval(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: CupertinoTheme.of(context)
                                .primaryColor
                                .withOpacity(0.2),
                            child: widget.group.imagePath != ''
                                ? Image.network(
                                    widget.group.imagePath!,
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
                      : CreateImageUtils.getGroupImageMemory(
                          selectedImagePath!, context,
                          small: false),
                ),
              ]),
              const SizedBox(height: 20),
              CupertinoTextField(
                placeholder: widget.group.name,
                controller: _groupNameController,
                focusNode: _nameFocus,
                onTapOutside: (pointer) {
                  _nameFocus.unfocus();
                },
                padding: const EdgeInsets.all(16),
                maxLines: 3,
                minLines: 1,
                suffix: CupertinoButton(
                  onPressed: () => _groupNameController.clear(),
                  child: const Icon(CupertinoIcons.clear_circled_solid),
                ),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                placeholder: widget.group.description,
                controller: _groupDescriptionController,
                focusNode: _descriptionFocus,
                onTapOutside: (pointer) {
                  _descriptionFocus.unfocus();
                },
                padding: const EdgeInsets.all(16),
                maxLines: 3,
                minLines: 1,
                suffix: CupertinoButton(
                  onPressed: () => _groupDescriptionController.clear(),
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
                child: Column(
                  children: [
                    CupertinoListTile(
                      title: const Text('Invite Followers'),
                      leading: const Icon(CupertinoIcons.person_3_fill),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () {
                        ref.invalidate(followerProvider);
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                              builder: (context) => InviteUserPage(
                                  invitePageKey: (String uuid) {
                                    setState(() {
                                      if (uuids.contains(uuid)) {
                                        uuids.remove(uuid);
                                      } else {
                                        uuids.add(uuid);
                                      }
                                    });
                                  },
                                  invitedUsers: uuids,
                                  id: widget.group.id)),
                        );
                      },
                    ),
                    Container(
                      height: 1,
                      color: CupertinoColors.separator,
                    ),
                    CupertinoListTile(
                      title: const Text('Categories'),
                      leading: const Icon(FontAwesomeIcons.tableList),
                      trailing: const Icon(CupertinoIcons.forward),
                      onTap: () {
                        if (widget.canNavigate) {
                          setState(() {
                            index = 1;
                          });
                          return;
                        }
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => CategoriesPage(
                              selectedCategories: selectedCategories,
                            ),
                          ),
                        );
                      },
                    ),
                    Container(
                      height: 1,
                      color: CupertinoColors.separator,
                    ),
                    CupertinoListTile(
                      leading: isPublic
                          ? const Icon(CupertinoIcons.lock_open_fill)
                          : const Icon(CupertinoIcons.lock_fill),
                      title: const Text('Public Group'),
                      trailing: CupertinoSwitch(
                        value: isPublic,
                        onChanged: (bool value) {
                          setState(() {
                            isPublic = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> updateGroup(DatabaseService databaseService) async {
    final group = Group(
      id: widget.group.id,
      name: _groupNameController.text,
      description: _groupDescriptionController.text,
      categories: selectedCategories,
      imagePath: widget.group.imagePath!,
      isPublic: isPublic,
    );
    await databaseService.updateGroup(
      group,
      selectedImagePath,
      selectedImagePath == null,
      widget.group.isPublic != isPublic,
      uuids,
    );
  }
}
