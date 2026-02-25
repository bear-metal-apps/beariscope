import 'package:beariscope/providers/post_sign_in_flow_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:libkoala/providers/user_profile_provider.dart';

enum _OnboardingStep { realName, emailVerification }

class PostSignInOnboardingPage extends ConsumerStatefulWidget {
  const PostSignInOnboardingPage({super.key});

  @override
  ConsumerState<PostSignInOnboardingPage> createState() =>
      _PostSignInOnboardingPageState();
}

class _PostSignInOnboardingPageState
    extends ConsumerState<PostSignInOnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  bool _isSavingName = false;
  bool _isFinishingFlow = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _finishFlow() async {
    ref.read(postSignInFlowPendingProvider.notifier).clearPending();
    if (mounted) {
      context.go('/up_next');
    }
  }

  List<_OnboardingStep> _requiredSteps(UserInfo userInfo) {
    final email = userInfo.email?.trim();
    final normalizedName = userInfo.name?.trim().toLowerCase();
    final normalizedEmail = email?.toLowerCase();

    final needsRealName =
        normalizedName == null ||
        normalizedName.isEmpty ||
        (normalizedEmail != null && normalizedName == normalizedEmail);

    final needsEmailVerification = userInfo.emailVerified != true;

    final steps = <_OnboardingStep>[];
    if (needsRealName) {
      steps.add(_OnboardingStep.realName);
    }
    if (needsEmailVerification) {
      steps.add(_OnboardingStep.emailVerification);
    }
    return steps;
  }

  void _scheduleFinishFlow() {
    if (_isFinishingFlow) {
      return;
    }

    _isFinishingFlow = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _finishFlow();
      if (mounted) {
        setState(() {
          _isFinishingFlow = false;
        });
      }
    });
  }

  String? _nameValidationError(String name, String? email) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return 'Enter your first and last name.';
    }

    final parts =
        trimmedName
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList();
    if (parts.length < 2) {
      return 'Please include both first and last name.';
    }

    if (trimmedName.toLowerCase() == email) {
      return 'Name cannot be the same as your email.';
    }

    final hasProperCapitalization = parts.asMap().entries.every(
      (entry) => _isProperlyCapitalizedNamePart(
        entry.value,
        isFirstPart: entry.key == 0,
      ),
    );
    if (!hasProperCapitalization) {
      return 'Use proper capitalization (for example: John Scout).';
    }

    if (trimmedName == 'John Scout') {
      return 'Nice try, but you aren\'t the real John Scout.';
    }

    return null;
  }

  bool _isProperlyCapitalizedNamePart(
    String part, {
    required bool isFirstPart,
  }) {
    const lowercaseParticles = {
      'de',
      'del',
      'da',
      'di',
      'du',
      'la',
      'le',
      'van',
      'von',
      'der',
      'den',
      'bin',
      'al',
      'ibn',
    };

    if (!isFirstPart && lowercaseParticles.contains(part.toLowerCase())) {
      return true;
    }

    final segments = part.split(RegExp(r"[-']"));
    for (final segment in segments) {
      if (segment.isEmpty) {
        return false;
      }

      if (!RegExp(r'^[A-Za-z]+$').hasMatch(segment)) {
        return false;
      }

      if (!RegExp(r'^[A-Z]').hasMatch(segment)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _saveRealName(String? email) async {
    final rawName = _nameController.text;
    final nameError = _nameValidationError(rawName, email);
    if (nameError != null) {
      return;
    }

    setState(() => _isSavingName = true);
    try {
      await ref
          .read(userProfileServiceProvider)
          .updateProfile(name: rawName.trim());
      final updatedUserInfo = await ref.refresh(userInfoProvider.future);

      if (updatedUserInfo != null && _requiredSteps(updatedUserInfo).isEmpty) {
        if (mounted) {
          setState(() => _isSavingName = false);
        }
        await _finishFlow();
        return;
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update name: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfoAsync = ref.watch(userInfoProvider);

    return Scaffold(
      body: userInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  const Text('Unable to load your account info right now.'),
                  FilledButton(
                    onPressed: () => ref.invalidate(userInfoProvider),
                    child: const Text('Try again'),
                  ),
                  TextButton(
                    onPressed: _finishFlow,
                    child: const Text('Continue to app'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (userInfo) {
          if (userInfo == null) {
            _scheduleFinishFlow();
            return const Center(child: CircularProgressIndicator());
          }

          final steps = _requiredSteps(userInfo);
          if (steps.isEmpty) {
            _scheduleFinishFlow();
            return const Center(child: CircularProgressIndicator());
          }

          final currentStep = steps.first;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(context, userInfo, currentStep),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    UserInfo userInfo,
    _OnboardingStep step,
  ) {
    switch (step) {
      case _OnboardingStep.realName:
        final nameError = _nameValidationError(
          _nameController.text,
          userInfo.email,
        );
        final isNameEmpty = _nameController.text.trim().isEmpty;
        final canSubmit = !_isSavingName && !isNameEmpty && nameError == null;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            const Text(
              'Set your real name',
              style: TextStyle(fontSize: 24, fontFamily: 'Xolonium'),
            ),
            const Text(
              'Using your real name helps teammates know who you are.',
            ),
            TextField(
              controller: _nameController,
              enabled: !_isSavingName,
              autofocus: true,
              textInputAction: TextInputAction.done,
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted: (_) {
                if (canSubmit) {
                  _saveRealName(userInfo.email);
                }
              },
              decoration: InputDecoration(
                labelText: 'Real name',
                hintText: 'First and last name',
                errorText: nameError,
                border: OutlineInputBorder(),
              ),
            ),
            FilledButton(
              onPressed: canSubmit ? () => _saveRealName(userInfo.email) : null,
              child:
                  _isSavingName
                      ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Text('Continue'),
            ),
          ],
        );
      case _OnboardingStep.emailVerification:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            const Text(
              'Verify your email',
              style: TextStyle(fontSize: 24, fontFamily: 'Xolonium'),
            ),
            Text(
              userInfo.email == null
                  ? 'Please check your inbox for a verification email. If you can\'t find it, reach out to an Apps lead for help!'
                  : 'Please check ${userInfo.email} for a verification email. If you can\'t find it, reach out to an Apps lead for help!',
            ),
            FilledButton(
              onPressed: () => ref.invalidate(userInfoProvider),
              child: const Text('Refresh verification status'),
            ),
            TextButton(
              onPressed: _finishFlow,
              child: const Text('Skip for now'),
            ),
          ],
        );
    }
  }
}
