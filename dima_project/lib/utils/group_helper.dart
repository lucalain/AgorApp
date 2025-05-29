import 'package:flutter/cupertino.dart';

class GroupHelper {
  static bool validateNameAndDescription(
      BuildContext context, String name, String description) {
    if (name.isEmpty) {
      _showErrorDialog(context, 'Group name is required');
      return false;
    }
    if (name.length > 20) {
      _showErrorDialog(context, 'Group name is too long');
      return false;
    }
    if (description.isEmpty) {
      _showErrorDialog(context, 'Group description is required');
      return false;
    }
    if (description.length > 150) {
      _showErrorDialog(context, 'Group description is too long');
      return false;
    }
    return true;
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
