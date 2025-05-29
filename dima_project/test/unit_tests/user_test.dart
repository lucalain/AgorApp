import 'package:dima_project/models/user.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User class tests', () {
    test('User constructor', () {
      UserData userData = UserData(
        categories: ['category1', 'category2'],
        imagePath: 'imagePath',
        email: 'email',
        password: 'password',
        name: 'name',
        surname: 'surname',
        username: 'username',
        uid: 'uid',
        isPublic: true,
        requests: ['request1', 'request2'],
        token: 'token',
      );
      expect(userData.categories, ['category1', 'category2']);
      expect(userData.imagePath, 'imagePath');
      expect(userData.email, 'email');
      expect(userData.password, 'password');
      expect(userData.name, 'name');
      expect(userData.surname, 'surname');
      expect(userData.username, 'username');
      expect(userData.uid, 'uid');
      expect(userData.isPublic, true);
      expect(userData.requests, ['request1', 'request2']);
      expect(userData.token, 'token');
    });
    test('Test fromSnapshot', () async {
      final firestore = FakeFirebaseFirestore();

      await firestore.collection('users').doc('userId').set({
        'name': 'name',
        'surname': 'surname',
        'username': 'username',
        'email': 'email',
        'imageUrl': 'imagePath',
        'selectedCategories': [
          {'value': 'category1'},
          {'value': 'category2'},
        ],
        'isPublic': true,
        'requests': ['request1', 'request2'],
        'token': 'token',
        'isSignedInWithGoogle': false,
        'groups': [],
      });

      final snapshot = await firestore.collection('users').doc('userId').get();

      UserData userData = UserData.fromSnapshot(snapshot);

      expect(userData.isSignedInWithGoogle, false);
      expect(userData.categories, ['category1', 'category2']);
      expect(userData.imagePath, 'imagePath');
      expect(userData.email, 'email');
      expect(userData.name, 'name');
      expect(userData.surname, 'surname');
      expect(userData.username, 'username');
      expect(userData.isPublic, true);
      expect(userData.requests, ['request1', 'request2']);
      expect(userData.token, 'token');
      expect(userData.groups, []);
    });
    test("Ensure fromSnapshot handles non-existent user data correctly",
        () async {
      final firestore = FakeFirebaseFirestore();

      final snapshot = await firestore.collection('users').doc('userId').get();

      UserData userData = UserData.fromSnapshot(snapshot);

      expect(userData.isSignedInWithGoogle, false);
      expect(userData.categories, []);
      expect(userData.imagePath, '');
      expect(userData.email, '');
      expect(userData.name, '');
      expect(userData.surname, '');
      expect(userData.username, 'Deleted Account');
      expect(userData.isPublic, false);
      expect(userData.requests, []);
      expect(userData.token, '');
    });
  });
}
