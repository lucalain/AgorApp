import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/option_item.dart';
import 'package:dima_project/widgets/chats/read_tile.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

class MessageUtils {
  static void showBottomSheet(
      BuildContext context, Message message, DatabaseService databaseService,
      {required VoidCallback? showCustomSnackbar}) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext newContext) {
        return CupertinoActionSheet(
          actions: [
            if (message.type == Type.text)
              _buildOptionItem(
                icon: CupertinoIcons.doc_on_clipboard,
                color: CupertinoColors.systemBlue,
                text: 'Copy Text',
                onPressed: () =>
                    _copyText(context, message, showCustomSnackbar!),
                context: newContext,
              ),
            if (message.type == Type.image)
              _buildOptionItem(
                icon: LineAwesomeIcons.download_solid,
                color: CupertinoColors.systemBlue,
                text: 'Save Image',
                onPressed: () => _saveImage(message, showCustomSnackbar!),
                context: newContext,
              ),
            if (message.sentByMe!)
              _buildOptionItem(
                icon: CupertinoIcons.delete,
                color: CupertinoColors.systemRed,
                text: 'Delete Message',
                onPressed: () =>
                    _deleteMessage(context, message, databaseService),
                context: newContext,
              ),
            if (message.sentByMe!)
              _buildOptionItem(
                icon: CupertinoIcons.eye_fill,
                color: CupertinoColors.systemBlue,
                text: 'Read By',
                onPressed: () => _showReaders(
                  context,
                  message,
                ),
                context: newContext,
              ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(newContext),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  static Widget _buildOptionItem(
      {required IconData icon,
      required Color color,
      required String text,
      required VoidCallback onPressed,
      required BuildContext context}) {
    return OptionItem(
      icon: Icon(icon, color: color, size: 26),
      text: text,
      onPressed: () {
        Navigator.pop(context);
        onPressed();
      },
    );
  }

  static Widget buildReadByIcon(
    Message message,
    DatabaseService databaseService,
  ) {
    bool hasRead =
        message.readBy!.any((element) => element.username == AuthService.uid);
    if (!hasRead) {
      databaseService.updateMessageReadStatus(message);
    }

    return message.sentByMe == true
        ? message.readBy!.isNotEmpty &&
                !message.readBy!
                    .every((element) => element.username == AuthService.uid)
            ? const Icon(LineAwesomeIcons.check_double_solid,
                color: CupertinoColors.white, size: 15)
            : const Icon(LineAwesomeIcons.check_solid,
                color: CupertinoColors.white, size: 15)
        : const SizedBox();
  }

  static Future<void> _copyText(BuildContext context, Message message,
      VoidCallback showCustomSnackbar) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) {
      debugPrint('Text copied to clipboard');
      showCustomSnackbar();
    }
  }

  static _saveImage(Message message, VoidCallback showCustomSnackbar) async {
    showCustomSnackbar();
    var response = await Dio().get(message.content,
        options: Options(responseType: ResponseType.bytes));
    await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
        quality: 60, name: const Uuid().v4());
  }

  static void _deleteMessage(
      BuildContext context, Message message, DatabaseService databaseService) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext newContext) {
        return CupertinoAlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('No'),
              onPressed: () {
                Navigator.pop(newContext);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                await databaseService.deleteMessage(message);
                if (newContext.mounted) Navigator.pop(newContext);
              },
            ),
          ],
        );
      },
    );
  }

  static void _showReaders(
    BuildContext context,
    Message message,
  ) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 16.0),
                      child: Text(
                        'Read By',
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: message.readBy!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reader = message.readBy![index];
                          if (message.sentByMe! &&
                              reader.username == AuthService.uid) {
                            return const SizedBox.shrink();
                          }
                          return ReadTile(
                            user: reader,
                            databaseService: DatabaseService(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
