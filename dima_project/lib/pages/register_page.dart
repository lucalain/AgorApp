import 'dart:typed_data';

import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/categories_form_widget.dart';
import 'package:dima_project/widgets/button_image_widget.dart';
import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class RegisterPage extends StatefulWidget {
  final User? user;
  final DatabaseService databaseService;
  final AuthService authService;
  const RegisterPage(
      {super.key,
      required this.user,
      required this.databaseService,
      required this.authService});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  int _currentPage = 1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  List<String> selectedCategories = [];
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEnteredWithGoogle = false;
  Uint8List selectedImagePath = Uint8List(0);
  String pageName = 'Credentials Information';
  @override
  void initState() {
    super.initState();
    if (widget.user != null && widget.user?.email != null) {
      _isEnteredWithGoogle = true;
      _currentPage = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (_currentPage) {
      case 2:
        page = PersonalInformationForm(
          nameController: _nameController,
          surnameController: _surnameController,
          usernameController: _usernameController,
        );
        pageName = 'Personal Information';
        break;
      case 3:
        page = Stack(children: [
          ButtonImageWidget(
            defaultImage: '',
            imageType: 0,
            imagePath: selectedImagePath,
            imagePicker: ImagePicker(),
            imageInsertPageKey: (Uint8List selectedImagePath) {
              setState(() {
                this.selectedImagePath = selectedImagePath;
              });
            },
            child: CreateImageUtils.getUserImageMemory(selectedImagePath,
                MediaQuery.of(context).size.width > Constants.limitWidth),
          ),
        ]);

        pageName = 'Profile Image';
        break;
      case 4:
        page = CategoriesForm(
          selectedCategories: selectedCategories,
        );
        pageName = 'Categories';
        break;
      default:
        page = CredentialsInformationForm(
          emailController: _emailController,
          passwordController: _passwordController,
        );
        pageName = 'Credentials Information';
        break;
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        transitionBetweenRoutes: false,
        trailing: _currentPage == 4
            ? CupertinoButton(
                padding: const EdgeInsets.all(3),
                onPressed: () => {managePage()},
                child: Text(
                  _isEnteredWithGoogle ? 'Sign in' : 'Register',
                  style: TextStyle(
                      fontSize: 16,
                      color: CupertinoTheme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              )
            : null,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            if (_currentPage == 1 && !_isEnteredWithGoogle) {
              context.go('/login');
            } else if (_currentPage == 2 && _isEnteredWithGoogle) {
              context.go('/login');
            } else {
              setState(() {
                _currentPage = _currentPage - 1;
              });
            }
          },
        ),
        middle: Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: Text(
            pageName,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > Constants.limitWidth
                  ? 20
                  : 17,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    page,
                    const SizedBox(height: 20.0),
                    if (_currentPage != 4)
                      CupertinoButton(
                          onPressed: () => {
                                if (_formKey.currentState!.validate())
                                  managePage()
                              },
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          color: CupertinoTheme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          child: _currentPage < 4
                              ? const Text(
                                  'Next',
                                  style:
                                      TextStyle(color: CupertinoColors.white),
                                )
                              : const SizedBox.shrink()),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              !_isEnteredWithGoogle && _currentPage != 4
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already a member?'),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                              color: CupertinoTheme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    selectedCategories.clear();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPassword.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> managePage() async {
    if (_currentPage == 1) {
      bool isEmailTaken =
          await widget.databaseService.isEmailTaken(_emailController.text);

      if (isEmailTaken) {
        debugPrint('Email is already taken');
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Email is already taken.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (_currentPage == 2) {
      bool isUsernameTaken = await widget.databaseService
          .isUsernameTaken(_usernameController.text);
      if (isUsernameTaken) {
        debugPrint('Username is already taken');
        if (!mounted) return;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Username is already taken.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (_currentPage < 4) {
      setState(() {
        _currentPage = _currentPage + 1;
      });
    } else {
      if (!mounted) return;
      if (selectedCategories.isEmpty) {
        debugPrint('Please select at least one category');
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Invalid choice'),
            content: const Text('Please select at least one category.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      } else {
        debugPrint('Registering user...');
        if (_isEnteredWithGoogle) {
          registerUserGoogle(
            UserData(
              name: _nameController.text,
              surname: _surnameController.text,
              email: widget.user!.email!,
              username: _usernameController.text,
              categories: selectedCategories,
              isSignedInWithGoogle: true,
            ),
            widget.user!.uid,
            selectedImagePath,
          );
        } else {
          // Register the user
          registerUser(
            UserData(
              isSignedInWithGoogle: false,
              name: _nameController.text,
              surname: _surnameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              username: _usernameController.text,
              categories: selectedCategories,
            ),
            selectedImagePath,
          );
        }
      }
    }
  }

  Future<void> registerUser(UserData user, Uint8List imagePath) async {
    // Register the user
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    try {
      await widget.authService.registerUser(
        user,
        imagePath,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      String errorMessage = e.toString();
      int errorCodeIndex = errorMessage.indexOf(']') + 1;
      String errorMessageSubstring =
          errorMessage.substring(errorCodeIndex).trim();
      debugPrint("Registration failed: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Registration Error'),
            content: Text('Registration failed: $errorMessageSubstring'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> registerUserGoogle(
      UserData userData, String uuid, Uint8List imagePath) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );
    await widget.databaseService
        .registerUserWithUUID(userData, uuid, imagePath);
    debugPrint('Navigating to Home Page');

    if (!mounted) return;
    Navigator.of(context).pop();
    context.go('/home');
  }
}
