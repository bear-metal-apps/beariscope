import 'package:beariscope/components/settings_group.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
    if (!_isDirty) {
      setState(() => _isDirty = true);
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
    _suppressDirty = false;
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(userProfileServiceProvider).updateProfile(
            name: _nameController.text,
            email: _emailController.text,
          );
      if (mounted) {
        setState(() => _isDirty = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (error) {
      debugPrint('Profile update failed: $error');
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

    setState(() => _isUploadingPhoto = true);
    try {
      await ref.read(userProfileServiceProvider).uploadProfilePhoto(
            bytes,
            contentType: lookupMimeType(file.name) ?? 'application/octet-stream',
            fileExtension: file.extension,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated')),
        );
      }
    } catch (error) {
      debugPrint('Photo upload failed: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    setState(() => _isSendingReset = true);
    try {
      await ref.read(userProfileServiceProvider).requestPasswordReset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } catch (error) {
      debugPrint('Password reset failed: $error');
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

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          SettingsGroup(
            title: 'Profile',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const ProfilePicture(size: 28),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _isUploadingPhoto ? null : _changePhoto,
                      icon: _isUploadingPhoto
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Symbols.photo_camera_rounded),
                      label: const Text('Change Photo'),
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
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed:
                            _isSaving || !_isDirty ? null : _saveProfile,
                        icon: _isSaving
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
                trailing: _isSendingReset
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                onTap: _isSendingReset ? null : _sendPasswordReset,
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
