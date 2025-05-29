import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class DeletedAccountWidget extends StatelessWidget {
  const DeletedAccountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: MediaQuery.of(context).size.width > Constants.limitWidth
            ? MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset(
                    'assets/darkMode/account_canceled_tablet.png',
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/account_canceled_tablet.png',
                    fit: BoxFit.cover,
                  )
            : MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset('assets/darkMode/account_canceled.png')
                : Image.asset('assets/images/account_canceled.png'),
      ),
    );
  }
}
