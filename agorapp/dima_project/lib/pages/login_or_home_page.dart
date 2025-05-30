import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class LoginOrHomePage extends StatefulWidget {
  const LoginOrHomePage({super.key});

  @override
  LoginOrHomePageState createState() => LoginOrHomePageState();
}

class LoginOrHomePageState extends State<LoginOrHomePage> {
  @override
  void initState() {
    super.initState();

    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("ERROR DURING AUTHENTICATION");
        }
        if (snapshot.hasData && FirebaseAuth.instance.currentUser != null) {
          AuthService.setUid(FirebaseAuth.instance.currentUser!.uid);
          return HomePage(
            index: 0,
            newsService: NewsService(),
            notificationService: NotificationService(
              databaseService: DatabaseService(),
            ),
          );
        } else {
          return LoginPage(
            databaseService: DatabaseService(),
            authService: AuthService(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
