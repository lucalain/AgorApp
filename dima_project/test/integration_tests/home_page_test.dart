import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks/mock_database_service.mocks.dart';
import '../mocks/mock_news_service.mocks.dart';
import '../mocks/mock_notification_service.mocks.dart';

void main() {
  testWidgets('Home Page Test', (WidgetTester tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final MockNewsService mockNewsService = MockNewsService();
    final MockNotificationService mockNotificationService =
        MockNotificationService();
    final MockDatabaseService mockDatabaseService = MockDatabaseService();

    when(mockNewsService.getSliders()).thenAnswer((_) => Future.value());
    when(mockNewsService.getNews()).thenAnswer((_) => Future.value());
    when(mockNewsService.sliders).thenAnswer((_) => ([]));
    when(mockNewsService.news).thenAnswer((_) => ([]));
    when(mockDatabaseService.getPrivateChatsStream())
        .thenAnswer((_) => Stream.value([]));
    when(mockDatabaseService.getGroupsStream())
        .thenAnswer((_) => Stream.value([]));
    await tester.pumpWidget(ProviderScope(
        overrides: [
          followerProvider.overrideWith(
            ((ref, uuid) async => []),
          ),
          followingProvider.overrideWith(
            ((ref, uuid) async => []),
          ),
          groupsProvider.overrideWith(
            ((ref, uuid) async => []),
          ),
          userProvider.overrideWith(
            ((ref, uuid) async => UserData(
                  name: 'name',
                  uid: 'uid',
                  imagePath: '',
                  email: 'email',
                  surname: 'surname',
                  categories: [],
                  groups: [],
                  username: 'username',
                )),
          ),
          joinedEventsProvider.overrideWith(
            ((ref, uuid) async => []),
          ),
          createdEventsProvider.overrideWith(
            ((ref, uuid) async => []),
          ),
          databaseServiceProvider.overrideWithValue(mockDatabaseService),
          notificationServiceProvider
              .overrideWithValue(mockNotificationService),
        ],
        child: CupertinoApp(
          home: HomePage(
              newsService: mockNewsService,
              notificationService: mockNotificationService),
        )));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.chat_bubble));
    await tester.pumpAndSettle();
    expect(find.text("Chats"), findsOneWidget);
    await tester.tap(find.byIcon(CupertinoIcons.calendar));
    await tester.pumpAndSettle();
    expect(find.text("Calendar"), findsNWidgets(2));
    await tester.tap(find.byIcon(CupertinoIcons.search));
    await tester.pumpAndSettle();
    expect(find.text("Search"), findsNWidgets(2));

    await tester.tap(find.byIcon(CupertinoIcons.home));
    await tester.pumpAndSettle();

    expect(find.text("username"), findsOneWidget);
    debugDefaultTargetPlatformOverride = null;
  });
}
