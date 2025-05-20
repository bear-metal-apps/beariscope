import 'package:beariscope/providers/auth_provider.dart';
import 'package:beariscope/widgets/text_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:simple_icons/simple_icons.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_clearErrors);
    _emailController.addListener(_clearErrors);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  Future<void> _signIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        TextInput.finishAutofillContext();
        context.go('/home');
      } else if (authProvider.error != null) {
        final error = authProvider.error!;
        if (error.contains('user_invalid_credentials')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect email or password')),
          );
        } else if (error.contains('password')) {
          setState(() => _passwordError = 'Invalid password');
        } else if (error.contains('email')) {
          setState(() => _emailError = 'Invalid email');
        } else if (error.contains('general_rate_limit_exceeded')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rate limit hit, please try again later'),
            ),
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        }
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SingleChildScrollView(
        child: Center(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 300,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Sign in with Apple'),
                    icon: const Icon(SimpleIcons.apple),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 300,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Sign in with Google'),
                    icon: const Icon(SimpleIcons.google),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 300,
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    label: const Text('Sign in with GitHub'),
                    icon: const Icon(SimpleIcons.github),
                  ),
                ),
                const SizedBox(height: 16),
                TextDivider(),
                const SizedBox(height: 16),
                AutofillGroup(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: const OutlineInputBorder(),
                          constraints: const BoxConstraints(
                            minWidth: 200,
                            maxWidth: 300,
                          ),
                          errorText: _emailError,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email Required';
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode);
                        },
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          constraints: const BoxConstraints(
                            minWidth: 200,
                            maxWidth: 300,
                          ),
                          errorText: _passwordError,
                        ),
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password required';
                          }
                          return null;
                        },
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isLoading ? null : _signIn,
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                          : const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
