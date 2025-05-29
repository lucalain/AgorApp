import 'dart:typed_data';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';

import '../mocks/mock_image_picker.mocks.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late Uint8List? pickedImage;

  setUp(() {
    mockImagePicker = MockImagePicker();
    pickedImage = null;
  });

  void onImagePicked(Uint8List image) {
    pickedImage = image;
  }

  Widget createTestWidget({Uint8List? imagePath}) {
    return CupertinoApp(
      home: ButtonImageWidget(
        imagePath: imagePath,
        imageInsertPageKey: onImagePicked,
        imageType: 0,
        defaultImage: 'path/to/default/image.png',
        imagePicker: mockImagePicker,
        child: const Text('Select Image'),
      ),
    );
  }

  testWidgets('Initial state is correct', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    // Verify the initial state - No image selected, child widget is displayed
    expect(find.text('Select Image'), findsOneWidget);
    expect(pickedImage, isNull);
  });

  testWidgets('Can pick image from gallery', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final Uint8List mockImageBytes = Uint8List.fromList([1, 2, 3]);
    final mockPickedFile = XFile.fromData(mockImageBytes);

    when(mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 500,
            maxWidth: 500,
            imageQuality: 80))
        .thenAnswer((_) async => mockPickedFile);

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set New Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(pickedImage, equals(mockImageBytes));
  });

  testWidgets('Can pick image from camera', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    final Uint8List mockImageBytes = Uint8List.fromList([4, 5, 6]);
    final mockPickedFile = XFile.fromData(mockImageBytes);

    when(mockImagePicker.pickImage(
            source: ImageSource.camera,
            maxHeight: 500,
            maxWidth: 500,
            imageQuality: 80))
        .thenAnswer((_) async => mockPickedFile);

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set New Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Camera'));
    await tester.pumpAndSettle();

    expect(pickedImage, equals(mockImageBytes));
  });

  testWidgets('Remove photo functionality works', (WidgetTester tester) async {
    final Uint8List initialImage = Uint8List.fromList([7, 8, 9]);
    await tester.pumpWidget(createTestWidget(imagePath: initialImage));

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove Photo'));
    await tester.pumpAndSettle();

    expect(pickedImage, isNotNull);
    expect(pickedImage, equals(Uint8List(0)));
  });

  testWidgets('Cancel button works in action sheet',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Ensure the action sheet is dismissed and no actions were taken
    expect(find.text('Set New Photo'), findsNothing);
    expect(pickedImage, isNull);
  });

  testWidgets('Cancel button works in camera/gallery selection',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set New Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Ensure the action sheet is dismissed and no actions were taken
    expect(find.text('Camera'), findsNothing);
    expect(find.text('Gallery'), findsNothing);
    expect(pickedImage, isNull);
  });

  testWidgets('Handles null image from picker gracefully',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    when(mockImagePicker.pickImage(
            source: ImageSource.gallery,
            maxHeight: 500,
            maxWidth: 500,
            imageQuality: 80))
        .thenAnswer((_) async => null);

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set New Photo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gallery'));
    await tester.pumpAndSettle();

    expect(pickedImage, isNull);
  });

  testWidgets('Default image is handled correctly when no image is selected',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget(imagePath: null));

    expect(find.text('Select Image'), findsOneWidget);
    expect(pickedImage, isNull);

    await tester.tap(find.text('Select Image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove Photo'));
    await tester.pumpAndSettle();

    // Ensure image is removed, which means it should be an empty Uint8List
    expect(pickedImage, isNotNull);
    expect(pickedImage, equals(Uint8List(0)));
  });
}
