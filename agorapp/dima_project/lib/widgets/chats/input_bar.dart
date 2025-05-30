import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class InputBar extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController messageEditingController;
  final void Function() onTapCamera;
  final void Function() sendMessage;
  final void Function() showOverlay;
  final String placeholderText;
  final Color buttonColor;
  final double height;
  final EdgeInsetsGeometry padding;
  final bool isGroupChat;

  const InputBar({
    super.key,
    required this.focusNode,
    required this.messageEditingController,
    required this.onTapCamera,
    required this.sendMessage,
    required this.showOverlay,
    this.placeholderText = "Type a message...",
    this.buttonColor = CupertinoColors.white,
    this.height = 50.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.inactiveGray,
      padding: padding,
      child: Row(
        children: [
          Focus(
            child: CupertinoButton(
              padding: const EdgeInsets.all(2),
              onPressed: () {
                focusNode.unfocus();
                showOverlay();
              },
              child: const Icon(CupertinoIcons.add,
                  color: CupertinoColors.white, size: 30),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: height,
              child: CupertinoTextField(
                onTapOutside: (pointer) {
                  if (MediaQuery.of(context).size.width >
                      Constants.limitWidth) {
                    if (pointer.position.dy < 330) {
                      focusNode.unfocus();
                    }
                  } else {
                    if (pointer.position.dy < 486) {
                      focusNode.unfocus();
                    }
                  }
                },
                focusNode: focusNode,
                minLines: 1,
                maxLines: 3,
                controller: messageEditingController,
                style: const TextStyle(color: CupertinoColors.white),
                placeholder: placeholderText,
                placeholderStyle: const TextStyle(color: CupertinoColors.white),
                decoration: BoxDecoration(
                  border: Border.all(color: CupertinoColors.white),
                  borderRadius: BorderRadius.circular(20),
                ),
                suffix: Container(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          messageEditingController.clear();
                        },
                        child: const Icon(CupertinoIcons.clear_circled,
                            color: CupertinoColors.white),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: onTapCamera,
                        child: const Icon(CupertinoIcons.camera_fill,
                            color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(2),
            color: buttonColor,
            onPressed: sendMessage,
            child: const Icon(LineAwesomeIcons.paper_plane,
                color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }
}
