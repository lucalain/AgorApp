import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

class CreateImageUtils {
  static Widget getUserImage(String imagePath, int size) {
    return ClipOval(
      child: Container(
        width: size == 0
            ? 30
            : size == 1
                ? 100
                : 200,
        height: size == 0
            ? 30
            : size == 1
                ? 100
                : 200,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != ''
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_user_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getGroupImage(String imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != ''
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_group_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getEventImage(String imagePath, BuildContext context,
      {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoTheme.of(context).primaryContrastingColor,
        child: imagePath != ''
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
              )
            : Padding(
                padding: small
                    ? const EdgeInsets.all(2.0)
                    : const EdgeInsets.all(15.0),
                child: CupertinoTheme.of(context).brightness == Brightness.light
                    ? Image.asset(
                        'assets/default_event_image_icon.png',
                        fit: BoxFit.scaleDown,
                        width: small ? 30 : 100,
                        height: small ? 30 : 100,
                      )
                    : Image.asset(
                        'assets/default_event_image_icon_dark.png',
                        fit: BoxFit.scaleDown,
                        width: small ? 30 : 100,
                        height: small ? 30 : 100,
                      ),
              ),
      ),
    );
  }

  static Widget getEventImageMemory(Uint8List image, BuildContext context,
      {bool small = true}) {
    return ClipOval(
      child: Container(
        width: small ? 60 : 100,
        height: small ? 60 : 100,
        color: CupertinoTheme.of(context).primaryColor.withOpacity(0.2),
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  CupertinoIcons.camera_fill,
                  size: small ? 30 : 40,
                  color:
                      CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  static Widget getUserImageMemory(Uint8List image, bool isTablet) {
    return ClipOval(
      child: Container(
        width: isTablet ? 200 : 100,
        height: isTablet ? 200 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_user_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getGroupImageMemory(Uint8List image, BuildContext context,
      {small = true}) {
    return ClipOval(
      child: Container(
        width: small ? 60 : 100,
        height: small ? 60 : 100,
        color: CupertinoTheme.of(context).primaryColor.withOpacity(0.2),
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Padding(
                padding: const EdgeInsets.all(15.0),
                child: Icon(
                  CupertinoIcons.camera_fill,
                  size: small ? 30 : 40,
                  color:
                      CupertinoTheme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
      ),
    );
  }

  static getImage(String content, bool sentByMe, {bool small = false}) {
    double size = small ? 30.0 : 200.0;

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft:
              sentByMe ? const Radius.circular(20) : const Radius.circular(0),
          bottomRight:
              sentByMe ? const Radius.circular(0) : const Radius.circular(20),
        ),
        child: CachedNetworkImage(
          errorWidget: (context, url, error) => Image.asset(
            "assets/generic_news.png",
            height: size,
            width: size,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
          errorListener: (error) {},
          imageUrl: content,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      ),
    );
  }
}
