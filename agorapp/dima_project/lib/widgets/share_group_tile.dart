import 'package:dima_project/models/group.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';

class ShareGroupTile extends StatefulWidget {
  final Group group;
  final ValueChanged<String> onSelected;
  final bool active;
  final bool isFirst;
  final bool isLast;
  @override
  const ShareGroupTile({
    super.key,
    required this.group,
    required this.onSelected,
    required this.active,
    required this.isFirst,
    required this.isLast,
  });

  @override
  State<ShareGroupTile> createState() => ShareGroupTileState();
}

class ShareGroupTileState extends State<ShareGroupTile> {
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
          onPressed: () {
            setState(() {
              isActive = !isActive;
            });
            widget.onSelected(widget.group.id);
          },
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
                child: CreateImageUtils.getGroupImage(widget.group.imagePath!),
              ),
            ),
            title: Text(
              widget.group.name,
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              widget.group.description!,
              style: TextStyle(
                color: CupertinoTheme.of(context).textTheme.textStyle.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
