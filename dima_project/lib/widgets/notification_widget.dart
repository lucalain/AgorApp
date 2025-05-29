import 'package:flutter/cupertino.dart';

class NotificationWidget extends StatefulWidget {
  final bool notify;
  final Function notifyFunction;
  const NotificationWidget(
      {super.key, required this.notify, required this.notifyFunction});

  @override
  NotificationWidgetState createState() => NotificationWidgetState();
}

class NotificationWidgetState extends State<NotificationWidget> {
  bool notify = false;
  @override
  void initState() {
    notify = widget.notify;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      padding: const EdgeInsets.all(0),
      title: Row(
        children: [
          notify
              ? const Icon(CupertinoIcons.bell)
              : const Icon(CupertinoIcons.bell_slash),
          const SizedBox(width: 10),
          const Text("Notifications"),
        ],
      ),
      trailing: Transform.scale(
        scale: 0.75,
        child: CupertinoSwitch(
          value: notify,
          onChanged: (bool value) {
            widget.notifyFunction(value);
            setState(() {
              notify = value;
            });
          },
        ),
      ),
    );
  }
}
