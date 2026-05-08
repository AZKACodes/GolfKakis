import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/util/phone_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../viewmodel/profile_detail_view_contract.dart';

class ProfileDetailView extends StatefulWidget {
  const ProfileDetailView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileDetailViewState state;
  final ValueChanged<ProfileDetailUserIntent> onUserIntent;

  @override
  State<ProfileDetailView> createState() => _ProfileDetailViewState();
}

class _ProfileDetailViewState extends State<ProfileDetailView> {
  static const _genderOptions = <String>[
    'Male',
    'Female',
    'Prefer not to say',
  ];

  late final TextEditingController _realNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _genderController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  final ImagePicker _imagePicker = ImagePicker();

  ProfileDetailDataLoaded get _loadedState {
    return switch (widget.state) {
      ProfileDetailDataLoaded() => widget.state as ProfileDetailDataLoaded,
    };
  }

  @override
  void initState() {
    super.initState();
    _realNameController = TextEditingController(text: _loadedState.realName);
    _usernameController = TextEditingController(text: _loadedState.username);
    _genderController = TextEditingController(text: _loadedState.gender);
    _dateOfBirthController = TextEditingController(
      text: _loadedState.dateOfBirth,
    );
    _emailController = TextEditingController(text: _loadedState.email);
    _phoneController = TextEditingController(text: _loadedState.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant ProfileDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_realNameController.text != _loadedState.realName) {
      _realNameController.text = _loadedState.realName;
    }
    if (_usernameController.text != _loadedState.username) {
      _usernameController.text = _loadedState.username;
    }
    if (_genderController.text != _loadedState.gender) {
      _genderController.text = _loadedState.gender;
    }
    if (_dateOfBirthController.text != _loadedState.dateOfBirth) {
      _dateOfBirthController.text = _loadedState.dateOfBirth;
    }
    if (_emailController.text != _loadedState.email) {
      _emailController.text = _loadedState.email;
    }
    if (_phoneController.text != _loadedState.phoneNumber) {
      _phoneController.text = _loadedState.phoneNumber;
    }
  }

  @override
  void dispose() {
    _realNameController.dispose();
    _usernameController.dispose();
    _genderController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _showProfileImageSourcePicker() async {
    await _requestGalleryPermission(showDeniedMessage: false);
    if (!mounted) {
      return;
    }

    final selection = await showModalBottomSheet<_ProfileImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'Change Profile Picture',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View Profile Picture'),
              onTap: () => Navigator.of(context).pop(_ProfileImageSource.view),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(_ProfileImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file_outlined),
              title: const Text('Choose from Files'),
              onTap: () => Navigator.of(context).pop(_ProfileImageSource.file),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || selection == null) {
      return;
    }

    // Let the bottom sheet fully dismiss before presenting another picker.
    await Future<void>.delayed(const Duration(milliseconds: 200));

    switch (selection) {
      case _ProfileImageSource.view:
        _showProfileImagePreview();
      case _ProfileImageSource.gallery:
        await _pickProfileImageFromGallery();
      case _ProfileImageSource.file:
        await _pickProfileImageFromFiles();
    }
  }

  Future<void> _pickProfileImageFromGallery() async {
    final hasPermission = await _requestGalleryPermission();
    if (!mounted || !hasPermission) {
      return;
    }

    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (!mounted || pickedFile == null) {
      return;
    }

    final storedPath = await _persistProfileImage(pickedFile.path);
    if (!mounted) {
      return;
    }

    widget.onUserIntent(OnProfileDetailAvatarImageChanged(storedPath));
  }

  void _showProfileImagePreview() {
    final state = _loadedState;
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
              const SizedBox(height: 8),
              _ProfileImagePreview(
                imagePath: state.avatarImagePath,
                initials: _buildInitials(state.realName),
                avatarIndex: state.avatarIndex,
              ),
              const SizedBox(height: 16),
              const Text(
                'Profile Picture',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestGalleryPermission({
    bool showDeniedMessage = true,
  }) async {
    if (Platform.isIOS) {
      final status = await Permission.photos.request();
      if (!mounted) {
        return false;
      }

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (showDeniedMessage) {
        _showAvatarPermissionMessage(
          status.isPermanentlyDenied
              ? 'Photo access is blocked. Please enable it in Settings to choose an image from your gallery.'
              : 'Photo access is required to choose an image from your gallery.',
        );
      }
      return false;
    }

    if (Platform.isAndroid) {
      final photoStatus = await Permission.photos.request();
      if (!mounted) {
        return false;
      }

      if (photoStatus.isGranted || photoStatus.isLimited) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      if (!mounted) {
        return false;
      }

      if (storageStatus.isGranted) {
        return true;
      }

      final isPermanentlyDenied =
          photoStatus.isPermanentlyDenied || storageStatus.isPermanentlyDenied;
      if (showDeniedMessage) {
        _showAvatarPermissionMessage(
          isPermanentlyDenied
              ? 'Gallery access is blocked. Please enable photo or storage access in Settings to choose an image.'
              : 'Gallery access is required to choose an image from your device.',
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _pickProfileImageFromFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final sourcePath = result?.files.single.path;
    if (!mounted || sourcePath == null || sourcePath.isEmpty) {
      return;
    }

    final storedPath = await _persistProfileImage(sourcePath);
    if (!mounted) {
      return;
    }

    widget.onUserIntent(OnProfileDetailAvatarImageChanged(storedPath));
  }

  void _showAvatarPermissionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<String> _persistProfileImage(String sourcePath) async {
    final sourceFile = File(sourcePath);
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final extensionIndex = sourcePath.lastIndexOf('.');
    final extension = extensionIndex >= 0
        ? sourcePath.substring(extensionIndex)
        : '';
    final targetPath =
        '${documentsDirectory.path}/profile_avatar_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedFile = await sourceFile.copy(targetPath);
    return savedFile.path;
  }

  Future<void> _showGenderPicker() async {
    final selectedGender = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'Select Gender',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ..._genderOptions.map(
              (gender) => ListTile(
                title: Text(gender),
                trailing: _genderController.text == gender
                    ? const Icon(Icons.check, color: Color(0xFF173B7A))
                    : null,
                onTap: () => Navigator.of(context).pop(gender),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || selectedGender == null) {
      return;
    }

    widget.onUserIntent(OnProfileDetailGenderChanged(selectedGender));
  }

  Future<void> _showDateOfBirthPicker() async {
    final now = DateTime.now();
    final lastAllowedDate = DateTime(now.year, now.month, now.day);
    final fallbackInitialDate = DateTime(
      now.year - 5,
      now.month,
      now.day,
    );
    final currentText = _dateOfBirthController.text.trim();
    final parsedCurrentDate = DateTime.tryParse(currentText);
    final initialDate = parsedCurrentDate != null &&
            !parsedCurrentDate.isAfter(lastAllowedDate)
        ? parsedCurrentDate
        : fallbackInitialDate;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: lastAllowedDate,
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final normalizedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';
    widget.onUserIntent(OnProfileDetailDateOfBirthChanged(normalizedDate));
  }

  Future<void> _startDeactivateFlow() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deactivate Account?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'This will log you out and remove your current session from this device.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD92D20),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Yes, Continue'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _showDeactivatePhoneConfirmationSheet();
  }

  Future<void> _showDeactivatePhoneConfirmationSheet() async {
    final phoneParts = PhoneUtil.splitPhoneNumber(_loadedState.phoneNumber);
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final phoneNumber = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confirm Your Phone Number',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Type your phone number to confirm account deactivation.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText:
                        '${phoneParts.countryCode.dialCode}${phoneParts.localNumber}',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your phone number to continue.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() != true) {
                        return;
                      }
                      Navigator.of(context).pop(controller.text.trim());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD92D20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: const Text('Deactivate Account'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();

    if (!mounted || phoneNumber == null || phoneNumber.isEmpty) {
      return;
    }

    widget.onUserIntent(
      OnProfileDetailDeactivateAccountConfirmed(phoneNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _loadedState;
    final phoneParts = PhoneUtil.splitPhoneNumber(state.phoneNumber);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                _EditableProfileAvatar(
                  imagePath: state.avatarImagePath,
                  initials: _buildInitials(state.realName),
                  avatarIndex: state.avatarIndex,
                  onTap: _showProfileImageSourcePicker,
                ),
                const SizedBox(height: 12),
                Text(
                  'Profile Picture',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Upload from your gallery or files.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Manage your account information below.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          if (state.message != null) ...[
            const SizedBox(height: 14),
            _Banner(
              message: state.message!,
              color: const Color(0xFFEAF6F0),
              borderColor: const Color(0xFFB8E0CA),
              textColor: const Color(0xFF1E5B4A),
            ),
          ],
          if (state.errorMessage != null) ...[
            const SizedBox(height: 14),
            _Banner(
              message: state.errorMessage!,
              color: const Color(0xFFFDECEC),
              borderColor: const Color(0xFFE7A1A1),
              textColor: const Color(0xFF8A3D3D),
            ),
          ],
          const SizedBox(height: 18),
          _ProfileField(
            controller: _realNameController,
            label: 'Name',
            icon: Icons.person_outline,
            readOnly: true,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _usernameController,
            label: 'Username',
            icon: Icons.alternate_email,
            onChanged: (value) =>
                widget.onUserIntent(OnProfileDetailUsernameChanged(value)),
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _genderController,
            label: 'Gender',
            icon: Icons.wc_outlined,
            readOnly: true,
            trailingIcon: Icons.keyboard_arrow_down_rounded,
            onTap: _showGenderPicker,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _dateOfBirthController,
            label: 'Date Of Birth',
            icon: Icons.cake_outlined,
            readOnly: true,
            trailingIcon: Icons.calendar_today_outlined,
            onTap: _showDateOfBirthPicker,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.email_outlined,
            onChanged: (value) =>
                widget.onUserIntent(OnProfileDetailEmailChanged(value)),
          ),
          const SizedBox(height: 14),
          _ProfileFieldDisplay(
            value: phoneParts.localNumber,
            label: 'Phone. No',
            icon: Icons.phone_outlined,
            prefixText: '${phoneParts.countryCode.dialCode} ',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isSaving
                  ? null
                  : () => widget.onUserIntent(const OnProfileDetailSaveClick()),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Save Profile'),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
                child: FilledButton(
                  onPressed: state.isSaving ? null : _startDeactivateFlow,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFFD92D20),
                foregroundColor: Colors.white,
              ),
              child: const Text('Deactivate Account'),
            ),
          ),
          if (state.isSaving) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }

  String _buildInitials(String value) {
    final parts = value
        .split(' ')
        .where((part) => part.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'U';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

enum _ProfileImageSource { view, gallery, file }

class _EditableProfileAvatar extends StatelessWidget {
  const _EditableProfileAvatar({
    required this.imagePath,
    required this.initials,
    required this.avatarIndex,
    required this.onTap,
  });

  final String? imagePath;
  final String initials;
  final int avatarIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final localImagePath = imagePath?.trim();
    final palette = _avatarPalettes[avatarIndex % _avatarPalettes.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: localImagePath == null || localImagePath.isEmpty
                ? LinearGradient(
                    colors: palette,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            image: localImagePath == null || localImagePath.isEmpty
                ? null
                : DecorationImage(
                    image: FileImage(File(localImagePath)),
                    fit: BoxFit.cover,
                  ),
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              if (localImagePath == null || localImagePath.isEmpty)
                Center(
                  child: Text(
                    initials,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              Positioned(
                right: 6,
                bottom: 6,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.photo_camera_outlined,
                    size: 16,
                    color: Color(0xFF173B7A),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileImagePreview extends StatelessWidget {
  const _ProfileImagePreview({
    required this.imagePath,
    required this.initials,
    required this.avatarIndex,
  });

  final String? imagePath;
  final String initials;
  final int avatarIndex;

  @override
  Widget build(BuildContext context) {
    final localImagePath = imagePath?.trim();
    final palette = _avatarPalettes[avatarIndex % _avatarPalettes.length];

    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: localImagePath == null || localImagePath.isEmpty
            ? LinearGradient(
                colors: palette,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: localImagePath == null || localImagePath.isEmpty
            ? null
            : DecorationImage(
                image: FileImage(File(localImagePath)),
                fit: BoxFit.cover,
              ),
      ),
      child: localImagePath == null || localImagePath.isEmpty
          ? Center(
              child: Text(
                initials,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : null,
    );
  }
}

const List<List<Color>> _avatarPalettes = [
  [Color(0xFF2F7BFF), Color(0xFF35C7A5)],
  [Color(0xFFFF9F1C), Color(0xFFFFD166)],
  [Color(0xFF9C4DFF), Color(0xFF5E60CE)],
  [Color(0xFF00A76F), Color(0xFF52B788)],
];

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.trailingIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: !readOnly || onTap != null,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: trailingIcon == null ? null : Icon(trailingIcon),
        filled: true,
        fillColor: const Color(0xFFF6F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF111827),
      ),
    );
  }
}

class _ProfileFieldDisplay extends StatelessWidget {
  const _ProfileFieldDisplay({
    required this.label,
    required this.icon,
    required this.value,
    this.prefixText,
  });

  final String label;
  final IconData icon;
  final String value;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: value),
      enabled: false,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        filled: true,
        fillColor: const Color(0xFFF6F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: const Color(0xFF111827),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.message,
    required this.color,
    required this.borderColor,
    required this.textColor,
  });

  final String message;
  final Color color;
  final Color borderColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
