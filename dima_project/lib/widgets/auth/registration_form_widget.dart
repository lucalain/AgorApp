import 'package:dima_project/widgets/auth/login_form_widget.dart';
import 'package:flutter/cupertino.dart';

class PersonalInformationForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController usernameController;

  const PersonalInformationForm({
    required this.nameController,
    required this.surnameController,
    super.key,
    required this.usernameController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.3),
      child: Column(
        children: [
          CupertinoTextFormFieldRow(
              controller: nameController,
              padding: const EdgeInsets.all(12.0),
              placeholder: 'Name',
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryContrastingColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                if (value.length > 20) {
                  return 'Name is too long';
                }
                return null; // Return null if the input is valid
              },
              prefix: const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(
                  CupertinoIcons.person_crop_circle_fill,
                  color: CupertinoColors.systemGrey,
                ),
              )),
          CupertinoTextFormFieldRow(
            controller: surnameController,
            padding: const EdgeInsets.all(12.0),
            placeholder: 'Surname',
            decoration: BoxDecoration(
              color: CupertinoTheme.of(context).primaryContrastingColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your surname';
              }
              if (value.length > 20) {
                return 'Surname is too long';
              }
              return null; // Return null if the input is valid
            },
            prefix: const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                CupertinoIcons.person_crop_circle_fill,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ),
          UsernameInputTextField(usernameController),
        ],
      ),
    );
  }
}

class UsernameInputTextField extends StatelessWidget {
  final TextEditingController usernameController;

  const UsernameInputTextField(this.usernameController, {super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoTextFormFieldRow(
      controller: usernameController,
      padding: const EdgeInsets.all(12.0),
      placeholder: 'Username',
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).primaryContrastingColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a username';
        }
        if (value.length > 20) {
          return 'Username is too long';
        }
        return null; // Return null if the input is valid
      },
      prefix: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(
          CupertinoIcons.person,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}

class CredentialsInformationForm extends StatelessWidget {
  final TextEditingController passwordController;
  final TextEditingController emailController;

  const CredentialsInformationForm({
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width / 1.3),
      child: Column(
        children: [
          EmailInputField(emailController),
          PasswordInputField(passwordController),
        ],
      ),
    );
  }
}
