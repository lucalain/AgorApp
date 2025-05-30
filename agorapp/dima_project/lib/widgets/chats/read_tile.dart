import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ReadTile extends StatefulWidget {
  final ReadBy user;
  final DatabaseService databaseService;
  const ReadTile(
      {super.key, required this.user, required this.databaseService});

  @override
  ReadTileState createState() => ReadTileState();
}

class ReadTileState extends State<ReadTile> {
  UserData? _userData;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final userData =
        await (widget.databaseService).getUserData(widget.user.username);

    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _userData == null
        ? Shimmer.fromColors(
            baseColor: CupertinoTheme.of(context).primaryContrastingColor,
            highlightColor: CupertinoTheme.of(context).primaryContrastingColor,
            child: CupertinoListTile(
              leading: ClipOval(
                child: Container(
                  width: 30,
                  height: 30,
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
              ),
              title: Container(
                width: 100,
                height: 50,
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
              subtitle: Container(
                width: 100,
                height: 50,
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
            ),
          )
        : CupertinoListTile(
            leading: CreateImageUtils.getUserImage(_userData!.imagePath!, 0),
            title: Text(
              _userData!.username,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch).isBefore(DateTime.now()) && DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 1))) ? 'Today' : DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 2))) ? 'Yesterday' : DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7))) ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch)) : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(widget.user.readAt.microsecondsSinceEpoch))} at ${DateUtil.getFormattedTime(context: context, time: widget.user.readAt.microsecondsSinceEpoch.toString())}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
  }
}
