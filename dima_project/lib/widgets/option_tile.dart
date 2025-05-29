import 'package:flutter/cupertino.dart';

class OptionTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;

  const OptionTile(
      {super.key, required this.leading, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(child: title),
            const Icon(CupertinoIcons.forward),
          ],
        ),
      ),
    );
  }
}
