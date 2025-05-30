import 'package:dima_project/widgets/category_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/utils/category_util.dart';

class CategoriesForm extends StatefulWidget {
  final List<String>? selectedCategories;
  const CategoriesForm({super.key, this.selectedCategories});
  @override
  CategoriesFormState createState() => CategoriesFormState();
}

class CategoriesFormState extends State<CategoriesForm> {
  late List<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: CategoryUtil.categories.map((category) {
          return CategoryItemWidget(
            title: category,
            icon: CategoryUtil.iconForCategory(category),
            onTap: () {
              setState(() {
                if (selectedCategories.contains(category)) {
                  selectedCategories.remove(category);
                } else {
                  selectedCategories.add(category);
                }
              });
            },
            selectedCategories: selectedCategories,
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
