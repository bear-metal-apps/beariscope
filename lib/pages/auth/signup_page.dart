import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var weakPassword = false;
  var emailAlreadyInUse = false;
  var _dropdownItems = <DropdownMenuItem<String>>[];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateErrorText);
    _confirmPasswordController.addListener(_updateErrorText);

    _getDropdownItems().then((items) {
      setState(() {
        _dropdownItems = items;
      });
    });
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

      try {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        context.go('/home');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            weakPassword = true;
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            emailAlreadyInUse = true;
          });
        }
      } catch (e) {
        FirebaseCrashlytics.instance.recordError(
          e,
          null,
          reason: 'Sign Up Error',
        );
      }
    }
  }

  Future<List<DropdownMenuItem<String>>> _getDropdownItems() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    final availableTeams = remoteConfig.getString('available_teams');
    final List<dynamic> teams = jsonDecode(availableTeams)['teams'];
    return teams.map<DropdownMenuItem<String>>((team) {
      return DropdownMenuItem<String>(
        value: team['number'].toString(),
        child: Text('${team['name']}, team ${team['number']}'),
      );
    }).toList();
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
                DropdownButtonFormField(
                  items: _dropdownItems,
                  onChanged: (value) {},
                  decoration: const InputDecoration(
                    labelText: 'Team',
                    border: OutlineInputBorder(),
                    constraints: BoxConstraints(minWidth: 200, maxWidth: 300),
                  ),
                ),
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
