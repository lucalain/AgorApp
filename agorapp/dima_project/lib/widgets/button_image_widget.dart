import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ButtonImageWidget extends StatefulWidget {
  final Uint8List? imagePath;
  final ValueChanged<Uint8List> imageInsertPageKey;
  final int imageType; // 0 for user, 1 for group, 2 for event
  final String defaultImage;
  final ImagePicker imagePicker;
  final Widget child;
  const ButtonImageWidget({
    super.key,
    this.imagePath,
    required this.imageInsertPageKey,
    required this.imageType,
    required this.defaultImage,
    required this.imagePicker,
    required this.child,
  });

  @override
  ButtonImageWidgetState createState() => ButtonImageWidgetState();
}

class ButtonImageWidgetState extends State<ButtonImageWidget> {
  late final ImagePicker _picker;
  Uint8List _selectedImagePath = Uint8List(0);
  String defaultImage = '';
  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker;
    _selectedImagePath = widget.imagePath ?? Uint8List(0);
    defaultImage = widget.defaultImage;
  }

  Future<void> _pickImage(bool isCamera) async {
    final pickedFile = await _picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      maxHeight: 500,
      maxWidth: 500,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImagePath = Uint8List.fromList(bytes);
        widget.imageInsertPageKey(_selectedImagePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(0),
      onPressed: () => showSheet(),
      child: widget.child,
    );
  }

  void showSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              showCameraOrGallery();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Set New Photo',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Remove Photo',
                  style: TextStyle(color: CupertinoColors.systemRed),
                )),
            onPressed: () {
              setState(() {
                _selectedImagePath = Uint8List(0);
                widget.imageInsertPageKey(_selectedImagePath);
                defaultImage = '';
              });
              Navigator.of(context).pop();
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel',
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void showCameraOrGallery() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(true);
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Camera',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(false);
              Navigator.of(context).pop();
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Gallery',
                style: TextStyle(
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text('Cancel',
              style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
