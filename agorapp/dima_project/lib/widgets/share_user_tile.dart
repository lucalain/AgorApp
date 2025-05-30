import 'package:dima_project/models/user.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';

class ShareUserTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> onSelected;
  final bool active;
  final bool isFirst;
  final bool isLast;
  @override
  const ShareUserTile({
    super.key,
    required this.user,
    required this.onSelected,
    required this.active,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<ShareUserTile> createState() => ShareUserTileState();
}

class ShareUserTileState extends State<ShareUserTile> {
  bool isActive = false;

  @override
  void initState() {
    setState(() {
      isActive = widget.active;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryContrastingColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.isFirst ? 10 : 0),
              topRight: Radius.circular(widget.isFirst ? 10 : 0),
              bottomLeft: Radius.circular(widget.isLast ? 10 : 0),
              bottomRight: Radius.circular(widget.isLast ? 10 : 0)),
        ),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          pressedOpacity: 1.0,
          child: CupertinoListTile(
            trailing: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isActive
                      ? CupertinoTheme.of(context).primaryColor
                      : CupertinoTheme.of(context).scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: isActive
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        color: CupertinoColors.white,
                        size: 15,
                      )
                    : Icon(
                        CupertinoIcons.circle,
                        color:
                            CupertinoTheme.of(context).scaffoldBackgroundColor,
                        size: 15,
                      )),
            leading: ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: CupertinoColors.lightBackgroundGray,
                child: CreateImageUtils.getUserImage(widget.user.imagePath!, 1),
              ),
            ),
            title: Text(
              widget.user.username,
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${widget.user.name} ${widget.user.surname}"),
          ),
          onPressed: () {
            setState(() {
              isActive = !isActive;
            });
            widget.onSelected(widget.user.uid!);
          },
        ),
      ),
    );
  }
}
