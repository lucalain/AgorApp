import 'package:flutter/cupertino.dart';

class CategoryItemWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final List<String> selectedCategories;

  const CategoryItemWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    required this.selectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedCategories.contains(title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 16.0),
                Text(title),
              ],
            ),
            isSelected
                ? Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: CupertinoTheme.of(context).primaryColor,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
