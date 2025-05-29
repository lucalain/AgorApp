import 'package:dima_project/widgets/auth/registration_form_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PersonalInformationForm Widget Tests', () {
    final nameController = TextEditingController();
    final surnameController = TextEditingController();
    final usernameController = TextEditingController();

    testWidgets('PersonalInformationForm renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: PersonalInformationForm(
            nameController: nameController,
            surnameController: surnameController,
            usernameController: usernameController,
          ),
        ),
      ));

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Surname'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('Name field validation works', (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                PersonalInformationForm(
                  nameController: nameController,
                  surnameController: surnameController,
                  usernameController: usernameController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      nameController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter your name'), findsOneWidget);

      nameController.text = 'This is a very long name that exceeds the limit';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Name is too long'), findsOneWidget);

      nameController.text = 'Valid Name';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Name is too long'), findsNothing);
      expect(find.text('Please enter your name'), findsNothing);
    });

    testWidgets('Surname field validation works', (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                PersonalInformationForm(
                  nameController: nameController,
                  surnameController: surnameController,
                  usernameController: usernameController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      surnameController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter your surname'), findsOneWidget);

      surnameController.text =
          'This is a very long surname that exceeds the limit';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Surname is too long'), findsOneWidget);

      surnameController.text = 'Valid Surname';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Surname is too long'), findsNothing);
      expect(find.text('Please enter your surname'), findsNothing);
    });

    testWidgets('Username field validation works', (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                PersonalInformationForm(
                  nameController: nameController,
                  surnameController: surnameController,
                  usernameController: usernameController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      usernameController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a username'), findsOneWidget);

      usernameController.text =
          'This is a very long username that exceeds the limit';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Username is too long'), findsOneWidget);

      usernameController.text = 'Valid Username';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Username is too long'), findsNothing);
      expect(find.text('Please enter a username'), findsNothing);
    });
  });
  group('CredentialsInformationForm Widget Tests', () {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    testWidgets('CredentialsInformationForm renders correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: CredentialsInformationForm(
            emailController: emailController,
            passwordController: passwordController,
          ),
        ),
      ));

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('Email field validation works', (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                CredentialsInformationForm(
                  emailController: emailController,
                  passwordController: passwordController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      emailController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      emailController.text = 'invalid email';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      emailController.text = 'email@example.com';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(find.text('Please enter your email'), findsNothing);
    });

    testWidgets('Password field validation works', (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                CredentialsInformationForm(
                  emailController: emailController,
                  passwordController: passwordController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));

      passwordController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a password'), findsOneWidget);

      passwordController.text = 'short';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters long'),
          findsOneWidget);

      passwordController.text = 'validpassword';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Password must be at least 6 characters long'),
          findsNothing);
      expect(find.text('Please enter a password'), findsNothing);
    });

    testWidgets('Confirm Password field validation works',
        (WidgetTester tester) async {
      final GlobalKey<FormState> formKey = GlobalKey<FormState>();
      await tester.pumpWidget(CupertinoApp(
        home: CupertinoPageScaffold(
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                CredentialsInformationForm(
                  emailController: emailController,
                  passwordController: passwordController,
                ),
                const SizedBox(height: 20.0),
                CupertinoButton(
                  onPressed: () => {formKey.currentState!.validate()},
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ));
      emailController.text = '';
      passwordController.text = '';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a password'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      emailController.text = 'email@gmail.com';
      passwordController.text = 'validpassword';
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(find.text('Please enter a password'), findsNothing);
      expect(find.text('Please enter a valid email address'), findsNothing);
    });
  });
}
