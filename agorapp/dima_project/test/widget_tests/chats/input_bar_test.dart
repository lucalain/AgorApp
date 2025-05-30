import 'package:dima_project/widgets/chats/input_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

void main() {
  group('InputBar Widget Tests', () {
    late FocusNode focusNode;
    late TextEditingController messageEditingController;
    late void Function() onTapCamera;
    late void Function() sendMessage;
    late void Function() showOverlay;

    setUp(() {
      focusNode = FocusNode();
      messageEditingController = TextEditingController();
      onTapCamera = () {};
      sendMessage = () {};
      showOverlay = () {};
    });

    tearDown(() {
      focusNode.dispose();
      messageEditingController.dispose();
    });

    testWidgets('InputBar Widget renders InputBar with default values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: InputBar(
              focusNode: focusNode,
              messageEditingController: messageEditingController,
              onTapCamera: onTapCamera,
              sendMessage: sendMessage,
              showOverlay: showOverlay,
            ),
          ),
        ),
      );

      expect(find.byType(InputBar), findsOneWidget);
      expect(
          find.text('Type a message...'), findsOneWidget); // Placeholder text
      expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
      expect(find.byIcon(LineAwesomeIcons.paper_plane), findsOneWidget);
    });

    testWidgets('InputBar Widget displays custom placeholder text',
        (WidgetTester tester) async {
      const customPlaceholder = 'Send a message';
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: InputBar(
              focusNode: focusNode,
              messageEditingController: messageEditingController,
              onTapCamera: onTapCamera,
              sendMessage: sendMessage,
              showOverlay: showOverlay,
              placeholderText: customPlaceholder,
            ),
          ),
        ),
      );

      expect(find.text(customPlaceholder), findsOneWidget);
    });

    testWidgets('InputBar Widget clears text when clear icon is tapped',
        (WidgetTester tester) async {
      messageEditingController.text = 'Hello, world!';
      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: InputBar(
              focusNode: focusNode,
              messageEditingController: messageEditingController,
              onTapCamera: onTapCamera,
              sendMessage: sendMessage,
              showOverlay: showOverlay,
            ),
          ),
        ),
      );

      expect(messageEditingController.text, 'Hello, world!');

      await tester.tap(find.byIcon(CupertinoIcons.clear_circled));
      await tester.pumpAndSettle();

      expect(messageEditingController.text, '');
    });

    testWidgets(
        'InputBar Widget calls sendMessage when paper plane icon is tapped',
        (WidgetTester tester) async {
      bool messageSent = false;
      sendMessage = () {
        messageSent = true;
      };

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: InputBar(
              focusNode: focusNode,
              messageEditingController: messageEditingController,
              onTapCamera: onTapCamera,
              sendMessage: sendMessage,
              showOverlay: showOverlay,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(LineAwesomeIcons.paper_plane));
      await tester.pumpAndSettle();

      expect(messageSent, true);
    });

    testWidgets('InputBar Widget calls onTapCamera when camera icon is tapped',
        (WidgetTester tester) async {
      bool cameraTapped = false;
      onTapCamera = () {
        cameraTapped = true;
      };

      await tester.pumpWidget(
        CupertinoApp(
          home: CupertinoPageScaffold(
            child: InputBar(
              focusNode: focusNode,
              messageEditingController: messageEditingController,
              onTapCamera: onTapCamera,
              sendMessage: sendMessage,
              showOverlay: showOverlay,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(CupertinoIcons.camera_fill));
      await tester.pumpAndSettle();

      expect(cameraTapped, true);
    });
  });
}
