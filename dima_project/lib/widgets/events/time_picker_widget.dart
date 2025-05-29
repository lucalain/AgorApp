import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TimePicker extends StatelessWidget {
  final DateTime initialTime;
  final ValueChanged<DateTime> onTimeChanged;

  const TimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(30),
      child: Icon(
        FontAwesomeIcons.clock,
        color: CupertinoTheme.of(context).primaryColor,
      ),
      onPressed: () => showSheet(
        context,
        initialTime: initialTime,
        onTimeChanged: onTimeChanged,
      ),
    );
  }

  static void showSheet(
    BuildContext context, {
    required DateTime initialTime,
    required ValueChanged<DateTime> onTimeChanged,
  }) {
    DateTime tempTime = initialTime;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              initialDateTime: tempTime,
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              minuteInterval: 15,
              onDateTimeChanged: (dateTime) {
                tempTime = dateTime;
              },
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Done'),
          onPressed: () {
            onTimeChanged(tempTime);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
