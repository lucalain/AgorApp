import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/chats/banner_message.dart';
import 'package:dima_project/widgets/chats/input_bar.dart';
import 'package:dima_project/widgets/chats/options_menu.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatPage extends ConsumerStatefulWidget {
  final bool canNavigate;
  final String groupId;
  final Function? navigateToPage;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  final StorageService storageService;
  final EventService eventService;
  const GroupChatPage({
    super.key,
    required this.canNavigate,
    this.navigateToPage,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
    required this.storageService,
    required this.eventService,
    required this.groupId,
  });

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends ConsumerState<GroupChatPage> {
  late final Stream<List<Message>> chats;
  TextEditingController messageEditingController = TextEditingController();
  bool isUploading = false;
  OverlayEntry? _optionsMenuOverlay;
  OverlayEntry? _clipboardOverlay;
  final GlobalKey _navigationBarKey = GlobalKey();
  final GlobalKey _inputBarKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  late final DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = widget.databaseService;
    getChats();
    super.initState();
  }

  void getChats() {
    chats = _databaseService.getChats(widget.groupId);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<Group> asyncValue =
        ref.watch(groupProvider(widget.groupId));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        key: _navigationBarKey,
        middle: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () async {
            ref.invalidate(userProvider);
            ref.invalidate(imagesGroupProvider);
            ref.invalidate(requestsGroupProvider);
            ref.invalidate(eventsGroupProvider);
            ref.invalidate(newsGroupProvider);
            ref.invalidate(groupProvider);

            if (!widget.canNavigate) {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => GroupInfoPage(
                    groupId: widget.groupId,
                    notificationService: widget.notificationService,
                    databaseService: _databaseService,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    imagePicker: widget.imagePicker,
                  ),
                ),
              );
            } else {
              widget.navigateToPage!(
                GroupInfoPage(
                  groupId: widget.groupId,
                  canNavigate: widget.canNavigate,
                  notificationService: widget.notificationService,
                  databaseService: _databaseService,
                  navigateToPage: widget.navigateToPage,
                  imagePicker: widget.imagePicker,
                ),
              );
              return;
            }
          },
          child: asyncValue.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(CupertinoIcons.arrow_left),
            data: (group) => Row(
              children: [
                CreateImageUtils.getGroupImage(group.imagePath!, small: true),
                const SizedBox(width: 10),
                Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.6),
                  child: Text(group.name,
                      style: TextStyle(
                        fontSize: 16,
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .textStyle
                            .color,
                      ),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        leading: widget.canNavigate
            ? null
            : CupertinoNavigationBarBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: CupertinoTheme.of(context).primaryColor,
              ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: chatMessages(),
          ),
          isUploading
              ? const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CupertinoActivityIndicator(),
                  ),
                )
              : Container(),
          InputBar(
            key: _inputBarKey,
            focusNode: _focusNode,
            messageEditingController: messageEditingController,
            onTapCamera: onTapCamera,
            sendMessage: sendMessage,
            showOverlay: () => showOverlay(context),
            padding: const EdgeInsets.only(right: 10, bottom: 20, top: 5),
            height: 50,
            buttonColor: CupertinoTheme.of(context).primaryColor,
            isGroupChat: true,
          )
        ],
      ),
    );
  }

  void showCustomSnackbar(bool isCopy) {
    if (mounted) {
      final RenderBox renderBox =
          _inputBarKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      _clipboardOverlay = OverlayEntry(
        builder: (context) => BannerMessage(
          size: size,
          canNavigate: widget.canNavigate,
          isCopy: isCopy,
        ),
      );
      Overlay.of(context).insert(_clipboardOverlay!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _clipboardOverlay?.remove();
        }
      });
    }
  }

  void onTapCreateEvent() async {
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
    if (widget.canNavigate) {
      widget.navigateToPage!(
        CreateEventPage(
          groupId: widget.groupId,
          canNavigate: widget.canNavigate,
          navigateToPage: widget.navigateToPage,
          imagePicker: widget.imagePicker,
          eventService: widget.eventService,
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateEventPage(
          groupId: widget.groupId,
          canNavigate: false,
          imagePicker: widget.imagePicker,
          eventService: widget.eventService,
        ),
      ),
    );
  }

  void onTapCamera() async {
    final ImagePicker picker = widget.imagePicker;
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }
      final bytes = await image.readAsBytes();
      final String imageUrl = await widget.storageService.uploadImageToStorage(
          'chat_images/${widget.groupId}/${AuthService.uid}/${Timestamp.now()}.jpg',
          Uint8List.fromList(bytes));
      ReadBy readBy = ReadBy(
        readAt: Timestamp.now(),
        username: AuthService.uid,
      );

      final Message message = Message(
        content: imageUrl,
        sender: AuthService.uid,
        isGroupMessage: true,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.image,
      );
      await _databaseService.sendMessage(widget.groupId, message);
      await widget.notificationService
          .sendGroupNotification(widget.groupId, message);
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void onTapPhoto() async {
    final ImagePicker picker = widget.imagePicker;
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      for (var image in images) {
        if (mounted) {
          setState(() {
            isUploading = true;
          });
        }

        final bytes = await image.readAsBytes();

        final String imageUrl = await widget.storageService.uploadImageToStorage(
            'chat_images/${widget.groupId}/${AuthService.uid}/${Timestamp.now()}.jpg',
            Uint8List.fromList(bytes));
        ReadBy readBy = ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        );

        final Message message = Message(
          content: imageUrl,
          sender: AuthService.uid,
          isGroupMessage: true,
          time: Timestamp.now(),
          readBy: [
            readBy,
          ],
          type: Type.image,
        );
        await _databaseService.sendMessage(widget.groupId, message);
        await widget.notificationService
            .sendGroupNotification(widget.groupId, message);
        if (mounted) {
          setState(() {
            isUploading = false;
          });
        }
      }
    }
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
  }

  Widget chatMessages() {
    return StreamBuilder<List<Message>>(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            reverse: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              final user = ref.watch(userProvider(message.sender));

              bool isSameDate = false;
              String? newDate = '';

              // Convert timestamp to DateTime
              final DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(
                  message.time.seconds * 1000);

              // Format the date
              final String date = DateUtil.formatDateBasedOnToday(messageDate);
              if (index == snapshot.data!.length - 1) {
                newDate = date;
              } else {
                final String prevDate = DateUtil.formatDateBasedOnToday(
                    DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data![index + 1].time.seconds * 1000));
                isSameDate = date == prevDate;
                newDate = isSameDate ? '' : date;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    newDate.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                newDate,
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    user.when(data: (user) {
                      message.senderImage = user.imagePath;
                      return _buildMessageTile(message, user.username);
                    }, error: (_, __) {
                      message.senderImage = '';
                      return _buildMessageTile(message, 'Deleted Account');
                    }, loading: () {
                      return Container();
                    })
                  ],
                ),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  void sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      ReadBy readBy = ReadBy(
        readAt: Timestamp.now(),
        username: AuthService.uid,
      );
      Message message = Message(
        content: messageEditingController.text,
        sender: AuthService.uid,
        isGroupMessage: true,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.text,
      );
      setState(() {
        messageEditingController.clear();
      });
      await _databaseService.sendMessage(widget.groupId, message);
      await widget.notificationService
          .sendGroupNotification(widget.groupId, message);
    }
  }

  void showOverlay(BuildContext context) {
    _optionsMenuOverlay = OverlayEntry(
      builder: (context) => OptionsMenu(
        onTapCreateEvent: onTapCreateEvent,
        onTapCamera: onTapCamera,
        onTapPhoto: onTapPhoto,
        overlayEntry: _optionsMenuOverlay,
        isTablet: widget.canNavigate,
      ),
    );

    Overlay.of(context).insert(_optionsMenuOverlay!);
  }

  @override
  void dispose() {
    if (_clipboardOverlay?.mounted ?? false) {
      _clipboardOverlay?.remove();
    }
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildMessageTile(Message message, String senderUsername) {
    switch (message.type) {
      case Type.text:
        return TextMessageTile(
          showCustomSnackbar: () {
            showCustomSnackbar(true);
          },
          focusNode: _focusNode,
          message: message,
          senderUsername: senderUsername,
          databaseService: _databaseService,
        );
      case Type.image:
        return ImageMessageTile(
          databaseService: _databaseService,
          notificationService: widget.notificationService,
          message: message,
          senderUsername: senderUsername,
          showCustomSnackbar: () {
            showCustomSnackbar(false);
          },
        );
      case Type.news:
        return NewsMessageTile(
          databaseService: _databaseService,
          message: message,
          senderUsername: senderUsername,
        );
      case Type.event:
      default:
        return EventMessageTile(
          message: message,
          senderUsername: senderUsername,
          databaseService: _databaseService,
        );
    }
  }
}
