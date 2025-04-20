import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var weakPassword = false;
  var emailAlreadyInUse = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateErrorText);
    _confirmPasswordController.addListener(_updateErrorText);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateErrorText() {
    setState(() {
      weakPassword = false;
      emailAlreadyInUse = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        heightFactor: 1.0,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 0),
                TextFormField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  autofillHints: [AutofillHints.name],
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_emailFocusNode);
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: [AutofillHints.email],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  obscureText: true,
                  autofillHints: [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocusNode);
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: const OutlineInputBorder(),
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 300,
                    ),
                    errorText:
                        (_passwordController.text !=
                                    _confirmPasswordController.text) &&
                                _confirmPasswordController.text != ''
                            ? 'Passwords do not match'
                            : null,
                  ),
                  obscureText: true,
                  autofillHints: [AutofillHints.newPassword],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm password required';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        weakPassword = false;
                        emailAlreadyInUse = false;
                      });

                      // Show loading indicator
                      final loadingOverlay = showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                      );

                      try {
                        final String email = _emailController.text;
                        final String name = _nameController.text;
                        final String password = _passwordController.text;

                        final Account account = Account(client);

                        final user = await account.create(
                          userId: ID.unique(),
                          email: email,
                          password: password,
                          name: name,
                        );

                        final session = await account
                            .createEmailPasswordSession(
                              email: email,
                              password: password,
                            );

                        // Dismiss loading indicator
                        Navigator.of(context).pop();

                        // Navigate to next screen
                        context.go('/welcome/signup/select_team');
                      } catch (e) {
                        // Dismiss loading indicator
                        Navigator.of(context).pop();

                        // Handle specific errors
                        if (e.toString().contains('weak-password')) {
                          setState(() {
                            weakPassword = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Password is too weak'),
                            ),
                          );
                        } else if (e.toString().contains(
                          'email-already-in-use',
                        )) {
                          setState(() {
                            emailAlreadyInUse = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Email is already in use'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: ${e.toString()}')),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
