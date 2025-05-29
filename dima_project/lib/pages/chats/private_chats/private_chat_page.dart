import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/chats/banner_message.dart';
import 'package:dima_project/widgets/chats/input_bar.dart';
import 'package:dima_project/widgets/chats/options_menu.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PrivateChatPage extends ConsumerStatefulWidget {
  final PrivateChat privateChat;
  final bool canNavigate;
  final Function? navigateToPage;
  final UserData user;
  final NotificationService notificationService;
  final DatabaseService databaseService;
  final ImagePicker imagePicker;
  final StorageService storageService;
  const PrivateChatPage({
    super.key,
    required this.privateChat,
    required this.canNavigate,
    this.navigateToPage,
    required this.user,
    required this.notificationService,
    required this.databaseService,
    required this.imagePicker,
    required this.storageService,
  });

  @override
  PrivateChatPageState createState() => PrivateChatPageState();
}

class PrivateChatPageState extends ConsumerState<PrivateChatPage> {
  Stream<List<Message>>? chats;
  TextEditingController messageEditingController = TextEditingController();
  final String uid = AuthService.uid;
  bool isUploading = false;
  final GlobalKey _inputBarKey = GlobalKey();
  OverlayEntry? _clipboardOverlay;
  OverlayEntry? _optionsMenuOverlay;
  final FocusNode _focusNode = FocusNode();
  late final DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = widget.databaseService;
    _checkPrivateChatId();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        middle: GestureDetector(
          onTap: () {
            if (widget.privateChat.id != null) {
              ref.invalidate(newsPrivateChatProvider);
              ref.invalidate(eventsPrivateChatProvider);
              ref.invalidate(imagesPrivateChatProvider);
              if (!widget.canNavigate) {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => PrivateInfoPage(
                    privateChat: widget.privateChat,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    user: widget.user,
                    notificationService: widget.notificationService,
                    databaseService: widget.databaseService,
                  ),
                ));
              } else {
                widget.navigateToPage!(
                  PrivateInfoPage(
                    privateChat: widget.privateChat,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    user: widget.user,
                    notificationService: widget.notificationService,
                    databaseService: widget.databaseService,
                  ),
                );
                return;
              }
            }
          },
          child: Row(
            children: [
              CreateImageUtils.getUserImage(
                widget.user.imagePath!,
                0,
              ),
              const SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Text(
                  widget.user.username,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: (!widget.canNavigate)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              )
            : null,
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
            padding: const EdgeInsets.only(right: 10, bottom: 20, top: 5),
            key: _inputBarKey,
            focusNode: _focusNode,
            messageEditingController: messageEditingController,
            onTapCamera: onTapCamera,
            sendMessage: sendMessage,
            showOverlay: () => showOverlay(context),
            buttonColor: CupertinoTheme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }

  void onTapCamera() async {
    final XFile? image = await widget.imagePicker
        .pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }
      final bytes = await image.readAsBytes();

      widget.privateChat.id ??=
          await _databaseService.createPrivateChat(widget.privateChat);
      final String imageUrl = await widget.storageService.uploadImageToStorage(
          'chat_images/${widget.privateChat.id!}/${AuthService.uid}/${Timestamp.now()}.jpg',
          Uint8List.fromList(bytes));
      ReadBy readBy = ReadBy(
        readAt: Timestamp.now(),
        username: AuthService.uid,
      );

      final Message message = Message(
        content: imageUrl,
        sender: AuthService.uid,
        isGroupMessage: false,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.image,
      );
      await _databaseService.sendMessage(widget.privateChat.id!, message);

      await widget.notificationService
          .sendPrivateChatNotification(widget.privateChat, message);
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void onTapPhoto() async {
    final List<XFile> images =
        await widget.imagePicker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      for (var image in images) {
        if (mounted) {
          setState(() {
            isUploading = true;
          });
        }
        final bytes = await image.readAsBytes();
        widget.privateChat.id ??=
            await _databaseService.createPrivateChat(widget.privateChat);

        final String imageUrl = await widget.storageService.uploadImageToStorage(
            'chat_images/${widget.privateChat.id!}/${AuthService.uid}/${Timestamp.now()}.jpg',
            Uint8List.fromList(bytes));
        ReadBy readBy = ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        );

        final Message message = Message(
          content: imageUrl,
          sender: AuthService.uid,
          isGroupMessage: false,
          time: Timestamp.now(),
          readBy: [
            readBy,
          ],
          type: Type.image,
        );
        await _databaseService.sendMessage(widget.privateChat.id!, message);
        await widget.notificationService.sendPrivateChatNotification(
          widget.privateChat,
          message,
        );
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
                    (message.type == Type.text)
                        ? TextMessageTile(
                            focusNode: _focusNode,
                            message: message,
                            databaseService: _databaseService,
                            showCustomSnackbar: () {
                              showCustomSnackbar(true);
                            },
                          )
                        : (message.type == Type.image)
                            ? ImageMessageTile(
                                databaseService: _databaseService,
                                notificationService: widget.notificationService,
                                message: message,
                                showCustomSnackbar: () {
                                  showCustomSnackbar(false);
                                },
                              )
                            : message.type == Type.news
                                ? NewsMessageTile(
                                    databaseService: _databaseService,
                                    message: message,
                                  )
                                : EventMessageTile(
                                    databaseService: _databaseService,
                                    message: message,
                                  ),
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

  void showCustomSnackbar(bool isCopy) {
    if (mounted) {
      final RenderBox renderBox =
          _inputBarKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      _clipboardOverlay = OverlayEntry(
        builder: (context) => BannerMessage(
            size: size, canNavigate: widget.canNavigate, isCopy: isCopy),
      );
      Overlay.of(context).insert(_clipboardOverlay!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _clipboardOverlay?.remove();
        }
      });
    }
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
        isGroupMessage: false,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.text,
      );
      setState(() {
        messageEditingController.clear();
      });
      widget.privateChat.id ??=
          await _databaseService.createPrivateChat(widget.privateChat);
      await _databaseService.sendMessage(widget.privateChat.id!, message);
      await widget.notificationService.sendPrivateChatNotification(
        widget.privateChat,
        message,
      );
    }
  }

  _checkPrivateChatId() async {
    final idStream = _databaseService
        .getPrivateChatIdFromMembers(widget.privateChat.members);

    await for (final id in idStream) {
      if (mounted) {
        setState(() {
          widget.privateChat.id = id;
          chats = _databaseService.getPrivateChats(widget.privateChat.id);
        });
      }
    }
  }

  void showOverlay(BuildContext context) {
    _optionsMenuOverlay = OverlayEntry(
        builder: (context) => OptionsMenu(
            isTablet: widget.canNavigate,
            onTapCamera: onTapCamera,
            onTapPhoto: onTapPhoto,
            overlayEntry: _optionsMenuOverlay));

    Overlay.of(context).insert(_optionsMenuOverlay!);
  }

  @override
  void dispose() {
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
    if (_clipboardOverlay?.mounted ?? false) {
      _clipboardOverlay?.remove();
    }
    _focusNode.dispose();
    super.dispose();
  }
}
