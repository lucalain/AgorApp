import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CustomSelectOption displays text and reacts to taps correctly',
      (WidgetTester tester) async {
    int selectedIndex = -1;
    const textLeft = 'Left';
    const textMiddle = 'Middle';
    const textRight = 'Right';

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomSelectionOption(
            textLeft: textLeft,
            textMiddle: textMiddle,
            textRight: textRight,
            onChanged: (idx) {
              selectedIndex = idx;
            },
          ),
        ),
      ),
    );

    expect(find.text(textLeft), findsOneWidget);
    expect(find.text(textMiddle), findsOneWidget);
    expect(find.text(textRight), findsOneWidget);

    await tester.tap(find.text(textLeft));
    await tester.pump();
    expect(selectedIndex, 0);

    await tester.tap(find.text(textMiddle));
    await tester.pump();
    expect(selectedIndex, 1);

    await tester.tap(find.text(textRight));
    await tester.pump();
    expect(selectedIndex, 2);
  });

  testWidgets('CustomSelectOption without middle text reacts to taps correctly',
      (WidgetTester tester) async {
    int selectedIndex = -1;
    const textLeft = 'Left';
    const textRight = 'Right';

    await tester.pumpWidget(
      CupertinoApp(
        home: CupertinoPageScaffold(
          child: CustomSelectionOption(
            textLeft: textLeft,
            textRight: textRight,
            onChanged: (idx) {
              selectedIndex = idx;
            },
          ),
        ),
      ),
    );

    expect(find.text(textLeft), findsOneWidget);
    expect(find.text(textRight), findsOneWidget);

    await tester.tap(find.text(textLeft));
    await tester.pump();
    expect(selectedIndex, 0);

    await tester.tap(find.text(textRight));
    await tester.pump();
    expect(selectedIndex, 1);
  });
}
