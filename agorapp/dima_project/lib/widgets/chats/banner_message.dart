import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BannerMessage extends StatelessWidget {
  final Size size;
  final bool canNavigate;
  final bool isCopy;
  const BannerMessage(
      {super.key,
      required this.size,
      required this.canNavigate,
      required this.isCopy});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: size.height,
      left: canNavigate ? MediaQuery.of(context).size.width * 0.4 : 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          padding:
              const EdgeInsets.only(right: 80, left: 10, bottom: 10, top: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: CupertinoTheme.of(context).primaryContrastingColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isCopy
                  ? Icon(
                      CupertinoIcons.rectangle_fill_on_rectangle_fill,
                      color: CupertinoTheme.of(context).primaryColor,
                    )
                  : Icon(
                      FontAwesomeIcons.download,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
              const SizedBox(width: 10),
              Text(
                isCopy ? "Copied to clipboard" : "Image saved to Photos",
                style:
                    TextStyle(color: CupertinoTheme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
