import 'package:flutter/cupertino.dart';

class CustomSelectionOption extends StatefulWidget {
  final String textLeft;
  final String? textMiddle;
  final String textRight;
  final int? initialIndex;
  final void Function(int idx) onChanged;

  const CustomSelectionOption({
    required this.textLeft,
    required this.textRight,
    this.textMiddle,
    required this.onChanged,
    this.initialIndex,
    super.key,
  });

  @override
  CustomSelectionOptionState createState() => CustomSelectionOptionState();
}

class CustomSelectionOptionState extends State<CustomSelectionOption> {
  late int idx;

  @override
  void initState() {
    idx = widget.initialIndex ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    idx = 0;
                    widget.onChanged(idx);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.textLeft,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: idx == 0
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.inactiveGray,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: idx == 0 ? 3 : 1,
                      color: idx == 0
                          ? CupertinoTheme.of(context).primaryColor
                          : CupertinoColors.opaqueSeparator,
                    ),
                  ],
                ),
              ),
            ),
            if (widget.textMiddle != null)
              Expanded(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    setState(() {
                      idx = 1;
                      widget.onChanged(idx);
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.textMiddle!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: idx == 1
                              ? CupertinoTheme.of(context).primaryColor
                              : CupertinoColors.inactiveGray,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: idx == 1 ? 3 : 1,
                        color: idx == 1
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.opaqueSeparator,
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  setState(() {
                    idx = widget.textMiddle != null ? 2 : 1;
                    widget.onChanged(idx);
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.textRight,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: idx == (widget.textMiddle != null ? 2 : 1)
                            ? CupertinoTheme.of(context).primaryColor
                            : CupertinoColors.inactiveGray,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height:
                          idx == (widget.textMiddle != null ? 2 : 1) ? 3 : 1,
                      color: idx == (widget.textMiddle != null ? 2 : 1)
                          ? CupertinoTheme.of(context).primaryColor
                          : CupertinoColors.opaqueSeparator,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
