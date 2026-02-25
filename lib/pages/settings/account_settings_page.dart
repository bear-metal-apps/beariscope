import 'package:beariscope/pages/settings/image_crop_dialog.dart';
import 'package:beariscope/components/settings_group.dart';
import 'package:beariscope/utils/image_processor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/libkoala.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mime/mime.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isDirty = false;
  bool _isSaving = false;
  bool _isUploadingPhoto = false;
  bool _isSendingReset = false;
  bool _suppressDirty = false;
  bool _nameTouched = false;
  bool _emailTouched = false;
  String? _originalName;
  String? _originalEmail;

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

  String? _nameValidationError(String name, String email) {
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

    if (trimmedName.toLowerCase() == email.trim().toLowerCase()) {
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

  String? _emailValidationError(String email) {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return 'Enter an email address.';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(trimmedEmail)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_markDirty);
    _emailController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (_suppressDirty) return;
    final isDirty =
        (_nameController.text != (_originalName ?? '')) ||
        (_emailController.text != (_originalEmail ?? ''));
    if (_isDirty != isDirty) {
      setState(() => _isDirty = isDirty);
    }
  }

  void _syncFromUser(UserInfo? user) {
    if (_isDirty) return;

    _suppressDirty = true;
    final name = user?.name ?? '';
    final email = user?.email ?? '';
    if (_nameController.text != name) {
      _nameController.text = name;
    }
    if (_emailController.text != email) {
      _emailController.text = email;
    }
    _originalName = name;
    _originalEmail = email;
    _nameTouched = false;
    _emailTouched = false;
    _suppressDirty = false;
  }

  Future<void> _saveProfile() async {
    final nameError = _nameValidationError(
      _nameController.text,
      _emailController.text,
    );
    final emailError = _emailValidationError(_emailController.text);
    if (nameError != null || emailError != null) {
      setState(() {});
      return;
    }

    setState(() => _isSaving = true);
    try {
      final updates = <String, String>{};
      if (_nameController.text != (_originalName ?? '')) {
        updates['name'] = _nameController.text.trim();
      }
      if (_emailController.text != (_originalEmail ?? '')) {
        updates['email'] = _emailController.text.trim();
      }
      if (updates.isNotEmpty) {
        await ref
            .read(userProfileServiceProvider)
            .updateProfile(name: updates['name'], email: updates['email']);
      }
      if (mounted) {
        setState(() {
          _isDirty = false;
          _originalName = _nameController.text.trim();
          _originalEmail = _emailController.text.trim();
          _nameController.text = _nameController.text.trim();
          _emailController.text = _emailController.text.trim();
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _changePhoto() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Select Photo',
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes;

    if (bytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to read image data')),
        );
      }
      return;
    }

    final mimeType =
        file.extension != null
            ? lookupMimeType('', headerBytes: bytes) ??
                lookupMimeType('file.${file.extension}')
            : lookupMimeType('', headerBytes: bytes);

    final convertedBytes = await ImageProcessor.convertToSupportedFormat(
      bytes,
      mimeType,
    );

    if (convertedBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to process image format')),
        );
      }
      return;
    }

    if (!mounted) return;
    final processedBytes = await ImageCropDialog.show(context, convertedBytes);

    if (processedBytes == null) {
      // cancelled
      return;
    }

    setState(() => _isUploadingPhoto = true);
    try {
      await ref
          .read(userProfileServiceProvider)
          .uploadProfilePhoto(
            processedBytes,
            contentType: 'image/jpeg',
            fileExtension: 'jpg',
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Sign Out'),
                content: const Text('Are you sure you want to sign out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    child: const Text('Sign Out'),
                  ),
                ],
              ),
        ) ??
        false;

    if (confirmed && context.mounted) {
      await ref.read(authProvider).logout();
    }
  }

  Future<void> _sendPasswordReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Password'),
            content: const Text(
              'Are you sure you want to send a password reset email?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Send'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isSendingReset = true);
    try {
      await ref.read(userProfileServiceProvider).requestPasswordReset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send reset email: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingReset = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.hasValue) {
      _syncFromUser(userInfo.value);
    }

    final nameError = _nameValidationError(
      _nameController.text,
      _emailController.text,
    );
    final emailError = _emailValidationError(_emailController.text);
    final showNameError = (_nameTouched || _isDirty) ? nameError : null;
    final showEmailError = (_emailTouched || _isDirty) ? emailError : null;
    final hasValidationErrors = nameError != null || emailError != null;
    final canSave = !_isSaving && _isDirty && !hasValidationErrors;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          SettingsGroup(
            title: 'Profile',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Tooltip(
                      message: 'Change profile photo',
                      child: InkWell(
                        onTap: _isUploadingPhoto ? null : _changePhoto,
                        borderRadius: BorderRadius.circular(100),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const ProfilePicture(size: 28),
                            Positioned(
                              bottom: -2,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.tertiaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainer,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Symbols.photo_camera_rounded,
                                  size: 12,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userInfo.value?.name ?? 'No Name',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userInfo.value?.email ?? 'No Email',
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Details',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      onChanged: (_) {
                        setState(() {
                          _nameTouched = true;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'First and last name',
                        errorText: showNameError,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      onChanged: (_) {
                        setState(() {
                          _emailTouched = true;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        errorText: showEmailError,
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: canSave ? _saveProfile : null,
                        icon:
                            _isSaving
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Symbols.save_rounded),
                        label: const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Security',
            children: [
              ListTile(
                leading: const Icon(Symbols.lock_reset_rounded),
                title: const Text('Reset Password'),
                subtitle: const Text('Send a password reset email'),
                trailing:
                    _isSendingReset
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                onTap: _isSendingReset ? null : _sendPasswordReset,
              ),
              ListTile(
                leading: Icon(
                  Symbols.logout_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: Text(
                  'Sign out of your account',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () => _signOut(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
