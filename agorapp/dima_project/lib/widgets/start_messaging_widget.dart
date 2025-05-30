import 'package:flutter/cupertino.dart';

class StartMessagingWidget extends StatelessWidget {
  const StartMessagingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chat_bubble_text,
            size: 100,
            color: CupertinoColors.systemGrey,
          ),
          Text('Select a chat to start messaging',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
