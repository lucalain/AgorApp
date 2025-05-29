import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;

  @override
  const ResponsiveLayout(
      {super.key, required this.mobileLayout, required this.tabletLayout});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > Constants.limitWidth) {
      return tabletLayout;
    } else {
      return mobileLayout;
    }
  }
}
