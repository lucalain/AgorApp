import 'dart:typed_data';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/categories_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/utils/group_helper.dart';
import 'package:dima_project/pages/chats/groups/invite_user_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  final bool canNavigate;
  final Function? navigateToPage;
  final ImagePicker imagePicker;
  const CreateGroupPage({
    super.key,
    this.navigateToPage,
    required this.canNavigate,
    required this.imagePicker,
  });

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  int _currentPage = 1;
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _groupDescriptionController =
      TextEditingController();
  Uint8List selectedImagePath = Uint8List(0);
  final imageInsertPageKey = GlobalKey<ButtonImageWidgetState>();
  List<String> selectedCategories = [];
  bool isPublic = true;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();

  List<String> uuids = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _groupNameController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = ref.read(databaseServiceProvider);

    Widget page;
    switch (_currentPage) {
      case 1:
        page = pageOneCreateGroup();
        break;
      case 2:
        page = pageTwoCreateGroup();
        break;
      default:
        page = pageOneCreateGroup();
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        trailing: _currentPage == 1
            ? CupertinoButton(
                padding: const EdgeInsets.all(3),
                onPressed: () => {managePage(databaseService)},
                child: Text(
                  'Create',
                  style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : null,
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: (widget.canNavigate && _currentPage == 1)
            ? CupertinoButton(
                padding: const EdgeInsets.all(3),
                onPressed: () {
                  widget.navigateToPage!(const StartMessagingWidget());
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : CupertinoNavigationBarBackButton(
                onPressed: () {
                  if (_currentPage == 1) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      _currentPage = 1;
                    });
                  }
                },
                color: CupertinoTheme.of(context).primaryColor,
              ),
        middle: Text(
          'Create Group',
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontSize: 25,
          ),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 20.0, left: 10.0, right: 10.0, bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              page,
            ],
          ),
        ),
      ),
    );
  }

  void createGroup(
      Group group, Uint8List imagePath, DatabaseService databaseService) async {
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
    await databaseService.createGroup(group, imagePath, uuids);
    if (buildContext.mounted) {
      Navigator.of(buildContext).pop();
    }
    if (mounted) {
      if (widget.canNavigate) {
        widget.navigateToPage!(const StartMessagingWidget());
        return;
      }
      Navigator.of(context).pop();
    }
  }

  Widget pageOneCreateGroup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(children: [
                        ButtonImageWidget(
                          imagePicker: widget.imagePicker,
                          defaultImage: '',
                          imageType: 1,
                          imagePath: selectedImagePath,
                          imageInsertPageKey: (Uint8List selectedImagePath) {
                            setState(() {
                              this.selectedImagePath = selectedImagePath;
                            });
                          },
                          child: CreateImageUtils.getGroupImageMemory(
                            selectedImagePath,
                            context,
                          ),
                        ),
                      ]),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width >
                              Constants.limitWidth)
                          ? MediaQuery.of(context).size.width * 0.5
                          : MediaQuery.of(context).size.width * 0.75,
                      child: CupertinoTextField(
                        focusNode: _nameFocus,
                        onTapOutside: (event) => _nameFocus.unfocus(),
                        controller: _groupNameController,
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                        padding: const EdgeInsets.all(16),
                        placeholder: 'Group Name',
                        suffix: CupertinoButton(
                          onPressed: () => _groupNameController.clear(),
                          child: const Icon(CupertinoIcons.clear_circled_solid),
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width:
                    (MediaQuery.of(context).size.width > Constants.limitWidth)
                        ? MediaQuery.of(context).size.width * 0.5 + 76
                        : MediaQuery.of(context).size.width * 0.75 + 76,
                child: CupertinoTextField(
                  minLines: 1,
                  focusNode: _descriptionFocus,
                  onTapOutside: (event) => _descriptionFocus.unfocus(),
                  controller: _groupDescriptionController,
                  placeholder: 'Group Description',
                  maxLines: 5,
                  maxLength: 200,
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).primaryContrastingColor,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  suffix: CupertinoButton(
                    onPressed: () => _groupDescriptionController.clear(),
                    child: const Icon(CupertinoIcons.clear_circled_solid),
                  ),
                ),
              ),
            ],
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
                            id: null,
                            invitedUsers: uuids)),
                  );
                },
              ),
              Container(
                height: 1,
                color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
              ),
              CupertinoListTile(
                title: const Text('Categories'),
                leading: const Icon(FontAwesomeIcons.tableList),
                trailing: const Icon(CupertinoIcons.forward),
                onTap: () {
                  if (widget.canNavigate) {
                    setState(() {
                      _currentPage = 2;
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
                color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
              ),
              CupertinoListTile(
                leading: isPublic
                    ? const Icon(CupertinoIcons.lock_open_fill)
                    : const Icon(CupertinoIcons.lock_fill),
                title: const Text('Public Group'),
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
    );
  }

  Widget pageTwoCreateGroup() {
    return SafeArea(
        child: CategoriesForm(
      selectedCategories: selectedCategories,
    ));
  }

  void managePage(DatabaseService databaseService) {
    if (!GroupHelper.validateNameAndDescription(
        context, _groupNameController.text, _groupDescriptionController.text)) {
      return;
    }
    createGroup(
      Group(
        name: _groupNameController.text,
        id: '',
        admin: AuthService.uid,
        description: _groupDescriptionController.text,
        categories: selectedCategories,
        isPublic: isPublic,
      ),
      selectedImagePath,
      databaseService,
    );
    ref.invalidate(groupsProvider(AuthService.uid));
  }
}
