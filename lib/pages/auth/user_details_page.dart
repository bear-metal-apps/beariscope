import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateErrorText() {
    setState(() {});
  }

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String email = _emailController.text;
      final String name = _firstNameController.text;
      final String password = _passwordController.text;
      final String confirmPassword = _confirmPasswordController.text;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 200,
                    maxWidth: 300,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          var uri = Uri.parse('https://flutter.dev');
                          if (!await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          )) {
                            throw 'Could not launch $uri';
                          }
                        },
                        label: Text('Add your team'),
                        icon: const Icon(Symbols.add_circle_rounded),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email Required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
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
                  onPressed: _signUp,
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
