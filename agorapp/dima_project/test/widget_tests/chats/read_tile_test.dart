import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/chats/read_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {
  @override
  Future<UserData> getUserData(String username) async {
    return UserData(
      username: 'user',
      imagePath: '',
      categories: ['category1', 'category2'],
      email: 'email',
      name: 'name',
      surname: 'surname',
    );
  }
}

void main() {
  MockDatabaseService mockDatabaseService = MockDatabaseService();

  testWidgets('Displays user data when userData is not null',
      (WidgetTester tester) async {
    Timestamp timestamp = Timestamp.fromDate(DateTime(2024, 1, 2));
    final readBy = ReadBy(username: 'user', readAt: timestamp);

    await tester.pumpWidget(
      CupertinoApp(
        home: ReadTile(user: readBy, databaseService: mockDatabaseService),
      ),
    );
    await tester.pump();

    expect(find.text('user'), findsOneWidget);
    expect(
        find.textContaining(DateFormat.yMd().format(
            DateTime.fromMicrosecondsSinceEpoch(
                timestamp.microsecondsSinceEpoch))),
        findsOneWidget);
  });
}
