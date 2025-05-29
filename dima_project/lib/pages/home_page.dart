import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/table_calendar_page.dart';
import 'package:dima_project/pages/chats/chat_page.dart';
import 'package:dima_project/pages/chats/chat_tablet_page.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/pages/news/news_page.dart';
import 'package:dima_project/pages/user_profile/user_profile_page.dart';
import 'package:dima_project/pages/user_profile/user_profile_tablet_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends ConsumerStatefulWidget {
  final int? index;
  final NewsService newsService;
  final NotificationService notificationService;
  const HomePage(
      {super.key,
      this.index,
      required this.newsService,
      required this.notificationService});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  late int? _currentIndex;
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {};
  late final NotificationService notificationServices;
  late final DatabaseService databaseService;
  late CupertinoTabController _tabController;
  Group? selectedGroup;
  PrivateChat? selectedPrivateChat;
  UserData? selectedUser;
  void clearNavigatorKeys() {
    _navigatorKeys.clear();
  }

  changeIndex(int index, Group? selectedGroup, PrivateChat? selectedPrivateChat,
      UserData? selectedUser) {
    ref.invalidate(userProvider);
    ref.invalidate(followerProvider);
    ref.invalidate(followingProvider);
    ref.invalidate(groupsProvider);
    ref.invalidate(joinedEventsProvider);
    ref.invalidate(createdEventsProvider);
    ref.invalidate(eventProvider);
    if (_currentIndex == index) {
      // Get the current tab's navigator key
      final navigatorKey = _navigatorKeys[index];
      // Pop to the first route of the current tab's navigator
      navigatorKey?.currentState?.popUntil((route) => route.isFirst);
    } else {
      setState(() {
        _currentIndex = index;
        _tabController.index = index;
      });
    }
    setState(() {
      this.selectedGroup = selectedGroup;
      this.selectedPrivateChat = selectedPrivateChat;
      this.selectedUser = selectedUser;
    });
  }

  @override
  void initState() {
    databaseService = ref.read(databaseServiceProvider);
    notificationServices = widget.notificationService;
    notificationServices.initialize(
        context, ref, changeIndex, clearNavigatorKeys);

    ref.read(userProvider(AuthService.uid));
    ref.read(followerProvider(AuthService.uid));
    ref.read(followingProvider(AuthService.uid));
    ref.read(groupsProvider(AuthService.uid));
    ref.read(joinedEventsProvider(AuthService.uid));
    ref.read(createdEventsProvider(AuthService.uid));

    super.initState();
    _currentIndex = widget.index ?? 0;
    _tabController = CupertinoTabController(initialIndex: _currentIndex!);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        currentIndex: _currentIndex!,
        onTap: (index) {
          changeIndex(index, selectedGroup, selectedPrivateChat, selectedUser);
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.news),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        late Widget page;
        switch (index) {
          case 0:
            page = NewsPage(
              newsService: widget.newsService,
            );
            break;
          case 1:
            page = ResponsiveLayout(
              mobileLayout: ChatPage(
                storageService: StorageService(),
                databaseService: databaseService,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
              ),
              tabletLayout: ChatTabletPage(
                storageService: StorageService(),
                databaseService: databaseService,
                selectedGroup: selectedGroup,
                selectedPrivateChat: selectedPrivateChat,
                selectedUser: selectedUser,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
                eventService: EventService(),
              ),
            );
            break;
          case 2:
            page = TableCalendarPage(
              imagePicker: ImagePicker(),
              eventService: EventService(),
            );
            break;
          case 3:
            page = SearchPage(
              databaseService: databaseService,
            );
            break;
          case 4:
            page = ResponsiveLayout(
              mobileLayout: UserProfile(
                user: AuthService.uid,
              ),
              tabletLayout: UserProfileTablet(
                user: AuthService.uid,
              ),
            );
            break;
          default:
            page = NewsPage(
              newsService: widget.newsService,
            );
        }
        // Initialize a GlobalKey for each tab's navigator
        _navigatorKeys.putIfAbsent(index, () => GlobalKey<NavigatorState>());
        return CupertinoTabView(
          navigatorKey: _navigatorKeys[index], // Assign the navigator key
          builder: (BuildContext context) {
            return page;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
