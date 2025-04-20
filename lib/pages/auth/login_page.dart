import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var invalidEmail = false;
  var invalidPassword = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateErrorText);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateErrorText() {
    setState(() {
      invalidEmail = false;
      invalidPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = context.read<Client>();

    return Scaffold(
      appBar: AppBar(title: const Text('Log In')),
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
                  controller: _emailController,
                  focusNode: _nameFocusNode,
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
                    if (invalidEmail) {
                      return 'Invalid email';
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
                  autofillHints: [AutofillHints.password],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    if (invalidPassword) {
                      return 'Invalid password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      setState(() {
                        invalidEmail = false;
                        invalidPassword = false;
                      });
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
                        final String password = _passwordController.text;

                        final Account account = Account(client);

                        final session = await account
                            .createEmailPasswordSession(
                              email: email,
                              password: password,
                            );

                        if (context.mounted) {
                          context.read<SharedPreferences>().setBool(
                            'isLoggedIn',
                            true,
                          );

                          // Dismiss loading indicator and go home
                          Navigator.of(context).pop();
                          context.go('/home');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          if (e.toString().contains('email')) {
                            setState(() {
                              invalidEmail = true;
                            });
                          } else if (e.toString().contains('password')) {
                            setState(() {
                              invalidPassword = true;
                            });
                          } else if (e.toString().contains(
                            'user_invalid_credentials',
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Account does not exist')),
                            );
                          } else {
                            // Show error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      }
                    }
                  },
                  child: const Text('Log In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
