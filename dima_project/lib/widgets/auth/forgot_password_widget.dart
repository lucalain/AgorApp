import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordForm extends StatelessWidget {
  final TextEditingController _usernameController;
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService authService;
  const ForgotPasswordForm(
    this._usernameController, {
    super.key,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Please enter your email to receive a password reset link',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          EmailInputField(
            _usernameController,
          ),
          const SizedBox(height: 20),
          CupertinoButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                resetPassword(context, _usernameController.text);
              }
            },
            padding: const EdgeInsets.symmetric(horizontal: 50),
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
            child: const Text(
              'Reset Password',
              style: TextStyle(
                color: CupertinoColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return const CupertinoAlertDialog(
          content: CupertinoActivityIndicator(),
        );
      },
    );

    try {
      await authService.sendPasswordResetEmail(email);
      debugPrint("Password reset email sent");
      if (!context.mounted) return;
      Navigator.of(context).pop();

      // Show success dialog
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Success'),
            content: const Text(
                'A password reset email has been sent to the email address provided.'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  context.go('/login');
                },
              ),
            ],
          );
        },
      );
    } catch (error) {
      String errorMessage = error.toString();
      int errorCodeIndex = errorMessage.indexOf(']') + 1;
      String errorMessageSubstring =
          errorMessage.substring(errorCodeIndex).trim();
      debugPrint("Error sending password reset email: $error");

      if (!context.mounted) return;
      Navigator.of(context).pop();
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(
                'Failed to send password reset email: ${errorMessageSubstring.toString()}'),
            actions: <Widget>[
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          );
        },
      );
    }
  }
}
