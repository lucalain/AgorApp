import 'package:flutter/cupertino.dart';

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String text;
  final VoidCallback onPressed;

  const OptionItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheetAction(
      onPressed: onPressed,
      child: Row(
        children: [
          icon,
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
