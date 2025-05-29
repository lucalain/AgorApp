import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class LoginForm extends ConsumerWidget {
  final TextEditingController _usernameController;
  final TextEditingController _passwordController;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final DatabaseService databaseService;
  final AuthService authService;
  const LoginForm(
    this._usernameController,
    this._passwordController, {
    super.key,
    required this.authService,
    required this.databaseService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmailInputField(_usernameController),
          PasswordInputField(_passwordController),
          CupertinoButton(
            onPressed: () {
              // Validate the form before proceeding
              if (_formKey.currentState!.validate()) {
                _checkCredentials(context, _usernameController.text,
                    _passwordController.text, ref);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 50),
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
            child: const Text('Login',
                style: TextStyle(color: CupertinoColors.white)),
          ),
          const SizedBox(height: 20),
          CupertinoButton(
              onPressed: () => _signInWithGoogle(context, ref),
              color: CupertinoColors.systemBlue,
              padding: const EdgeInsets.symmetric(horizontal: 50),
              borderRadius: BorderRadius.circular(20),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(
                    FontAwesomeIcons.google,
                    color: CupertinoColors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Sign In with Google',
                    style: TextStyle(
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _checkCredentials(BuildContext context, String email,
      String password, WidgetRef ref) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    try {
      await authService.signInWithEmailAndPassword(
        email,
        password,
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
      debugPrint("Navigating to Home Page");
      //pass the user object to the home page
      ref.invalidate(userProvider);

      context.go('/home');
    } catch (e) {
      String errorMessage = e.toString();
      int errorCodeIndex = errorMessage.indexOf(']') + 1;
      String errorMessageSubstring =
          errorMessage.substring(errorCodeIndex).trim();
      Navigator.of(context).pop();
      debugPrint("Failed to login: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content: Text('Failed to login: $errorMessageSubstring'),
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

  Future<void> _signInWithGoogle(BuildContext context, WidgetRef ref) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    try {
      final User? user = await authService.signInWithGoogle();

      if (user == null) {
        throw Exception("Failed to login with Google");
      }
      final bool userExists = await databaseService.checkUserExist(user.email!);

      if (!userExists) {
        if (!context.mounted) return;
        Navigator.of(context).pop();
        context.go('/register', extra: user);
      } else {
        debugPrint("Navigating to Home Page");

        if (!context.mounted) return;
        Navigator.of(context).pop();

        ref.invalidate(userProvider);
        context.go('/home');
      }
    } catch (e) {
      Navigator.of(context).pop();
      // Handle other exceptions
      debugPrint("Failed to login: $e");
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Login Failed'),
            content:
                const Text('Failed to login with Google. Please try again.'),
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
}

class PasswordInputField extends StatefulWidget {
  final TextEditingController _passwordController;

  const PasswordInputField(
    this._passwordController, {
    super.key,
  });

  @override
  PasswordInputFieldState createState() => PasswordInputFieldState();
}

class PasswordInputFieldState extends State<PasswordInputField> {
  late final TextEditingController _passwordController;
  late final bool isConfirmPassword;
  late final TextEditingController? confirmValue;
  @override
  void initState() {
    super.initState();
    _passwordController = widget._passwordController;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _passwordController,
      placeholder: 'Password',
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryContrastingColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 2.0,
          )),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
      obscureText: true,
      prefix: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          CupertinoIcons.lock,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}

class EmailInputField extends StatelessWidget {
  final TextEditingController _emailController;

  const EmailInputField(this._emailController, {super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: _emailController,
      placeholder: 'Email',
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryContrastingColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: CupertinoColors.systemGrey4,
            width: 2.0,
          )),
      validator: (String? value) {
        final RegExp emailRegex = RegExp(
          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          caseSensitive: false,
          multiLine: false,
        );
        if (value == null || value.isEmpty || !emailRegex.hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null; // Return null if the input is valid
      },
      prefix: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          CupertinoIcons.mail,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
