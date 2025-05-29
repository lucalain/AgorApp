import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/show_images_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageViewPage extends ConsumerStatefulWidget {
  final Message media;
  final List<Message> messages;
  final bool canNavigate;
  final Function? navigateToPage;
  final bool isGroup;
  final String? groupId;
  final PrivateChat? privateChat;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final UserData? user;
  const ImageViewPage(
      {super.key,
      required this.media,
      required this.messages,
      required this.canNavigate,
      required this.isGroup,
      this.privateChat,
      this.groupId,
      this.navigateToPage,
      required this.databaseService,
      required this.notificationService,
      this.user});

  @override
  ImageViewPageState createState() => ImageViewPageState();
}

class ImageViewPageState extends ConsumerState<ImageViewPage> {
  late PageController _pageController;
  late int initialPage;
  late final DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = widget.databaseService;

    initialPage =
        widget.messages.indexWhere((message) => message.id == widget.media.id);
    _pageController = PageController(initialPage: initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<AsyncValue<UserData>> users = [];
    for (var message in widget.messages) {
      users.add(ref.watch(userProvider(message.sender)));
    }
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false,
              transitionBetweenRoutes: false,
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              leading: CupertinoNavigationBarBackButton(
                onPressed: () {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(ShowImagesPage(
                        isGroup: widget.isGroup,
                        medias: widget.messages,
                        canNavigate: widget.canNavigate,
                        groupId: widget.groupId,
                        privateChat: widget.privateChat,
                        navigateToPage: widget.navigateToPage,
                        databaseService: _databaseService,
                        notificationService: widget.notificationService,
                        user: widget.user));

                    return;
                  }
                  Navigator.of(context).pop();
                },
                color: CupertinoTheme.of(context).primaryColor,
              ),
              middle: SingleChildScrollView(
                  child: users[index].when(
                      loading: () => const Center(child: SizedBox.shrink()),
                      error: (error, stack) => const Text('Error'),
                      data: (user) {
                        return _buildUserInfoRow(user.username,
                            message.time.microsecondsSinceEpoch.toString());
                      })),
            ),
            child: _buildImageView(message));
      },
    );
  }

  Widget _buildImageView(Message message) {
    return Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: message.content,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              const Icon(CupertinoIcons.photo_fill),
          errorListener: (value) {},
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String username, String timestamp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Text(
            overflow: TextOverflow.ellipsis,
            username,
            style: TextStyle(
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          DateUtil.getFormattedDateAndTime(context: context, time: timestamp),
          style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
