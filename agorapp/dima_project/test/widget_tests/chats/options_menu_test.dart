import 'package:dima_project/widgets/chats/options_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OptionsMenu Widget Tests', () {
    late VoidCallback onTapCreateEvent;
    late VoidCallback onTapCamera;
    late VoidCallback onTapPhoto;
    late OverlayEntry overlayEntry;

    setUp(() {
      onTapCreateEvent = () {};
      onTapCamera = () {};
      onTapPhoto = () {};
      overlayEntry = OverlayEntry(builder: (context) => const SizedBox());
    });

    tearDown(() {
      if (overlayEntry.mounted) overlayEntry.remove();
    });

    testWidgets('It renders OptionsMenu with Event option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OptionsMenu(
              onTapCreateEvent: onTapCreateEvent,
              onTapCamera: onTapCamera,
              onTapPhoto: onTapPhoto,
              overlayEntry: overlayEntry,
              isTablet: false,
            ),
          ),
        ),
      );

      expect(find.byType(OptionsMenu), findsOneWidget);
      expect(find.text('Event'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Photo'), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.calendar), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.camera_fill), findsOneWidget);
      expect(find.byIcon(CupertinoIcons.photo_fill), findsOneWidget);
    });

    testWidgets('It renders OptionsMenu without Event option',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OptionsMenu(
              onTapCamera: onTapCamera,
              onTapPhoto: onTapPhoto,
              overlayEntry: overlayEntry,
              isTablet: false,
            ),
          ),
        ),
      );

      expect(find.byType(OptionsMenu), findsOneWidget);
      expect(find.text('Event'), findsNothing);
    });

    testWidgets('It calls onTapCreateEvent when Event is tapped',
        (WidgetTester tester) async {
      bool createEventTapped = false;

      onTapCreateEvent = () {
        createEventTapped = true;
      };

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OptionsMenu(
              onTapCreateEvent: onTapCreateEvent,
              onTapCamera: onTapCamera,
              onTapPhoto: onTapPhoto,
              overlayEntry: overlayEntry,
              isTablet: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Event'));
      await tester.pumpAndSettle();

      expect(createEventTapped, true);
    });

    testWidgets('It calls onTapCamera when Camera is tapped',
        (WidgetTester tester) async {
      bool cameraTapped = false;

      onTapCamera = () {
        cameraTapped = true;
      };

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OptionsMenu(
              onTapCreateEvent: onTapCreateEvent,
              onTapCamera: onTapCamera,
              onTapPhoto: onTapPhoto,
              overlayEntry: overlayEntry,
              isTablet: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Camera'));
      await tester.pumpAndSettle();

      expect(cameraTapped, true);
    });

    testWidgets('It calls onTapPhoto when Photo is tapped',
        (WidgetTester tester) async {
      bool photoTapped = false;

      onTapPhoto = () {
        photoTapped = true;
      };

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: OptionsMenu(
              onTapCreateEvent: onTapCreateEvent,
              onTapCamera: onTapCamera,
              onTapPhoto: onTapPhoto,
              overlayEntry: overlayEntry,
              isTablet: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Photo'));
      await tester.pumpAndSettle();

      expect(photoTapped, true);
    });
  });
}
