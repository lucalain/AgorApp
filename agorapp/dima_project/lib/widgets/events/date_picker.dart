import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DatePicker extends StatelessWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DatePicker({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(30),
      child: Icon(
        FontAwesomeIcons.calendar,
        color: CupertinoTheme.of(context).primaryColor,
      ),
      onPressed: () => _showDatePickerSheet(context),
    );
  }

  void _showDatePickerSheet(BuildContext context) {
    DateTime selectedDateTime = initialDateTime;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              minimumYear: DateTime.now().year,
              initialDateTime: selectedDateTime,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (dateTime) {
                selectedDateTime = dateTime;
              },
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Done'),
          onPressed: () {
            onDateTimeChanged(selectedDateTime);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
