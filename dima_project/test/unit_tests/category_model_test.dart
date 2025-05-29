import 'package:dima_project/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CategoryModel constructor', () {
    CategoryModel categoryModel = CategoryModel(
      categoryName: 'categoryName',
      image: 'image',
    );
    expect(categoryModel.categoryName, 'categoryName');
    expect(categoryModel.image, 'image');
  });
}
