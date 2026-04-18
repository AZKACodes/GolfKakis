import 'package:flutter/material.dart';

import '../viewmodel/profile_edit_view_contract.dart';

class ProfileEditView extends StatefulWidget {
  const ProfileEditView({
    required this.state,
    required this.onFullNameChanged,
    required this.onNicknameChanged,
    required this.onOccupationChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onAvatarChanged,
    required this.onSaveClick,
    super.key,
  });

  final ProfileEditViewState state;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onOccupationChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<int> onAvatarChanged;
  final VoidCallback onSaveClick;

  @override
  State<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _occupationController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.state.fullName);
    _nicknameController = TextEditingController(text: widget.state.nickname);
    _occupationController = TextEditingController(
      text: widget.state.occupation,
    );
    _emailController = TextEditingController(text: widget.state.email);
    _phoneController = TextEditingController(text: widget.state.phoneNumber);
  }

  @override
  void didUpdateWidget(covariant ProfileEditView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_fullNameController.text != widget.state.fullName) {
      _fullNameController.text = widget.state.fullName;
    }
    if (_nicknameController.text != widget.state.nickname) {
      _nicknameController.text = widget.state.nickname;
    }
    if (_occupationController.text != widget.state.occupation) {
      _occupationController.text = widget.state.occupation;
    }
    if (_emailController.text != widget.state.email) {
      _emailController.text = widget.state.email;
    }
    if (_phoneController.text != widget.state.phoneNumber) {
      _phoneController.text = widget.state.phoneNumber;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _occupationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                _EditableAvatar(
                  initials: _buildInitials(widget.state.fullName),
                  avatarIndex: widget.state.avatarIndex,
                  onTap: () => widget.onAvatarChanged(
                    (widget.state.avatarIndex + 1) % _avatarPalettes.length,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Profile Picture',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the avatar to cycle styles or choose one below.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: List<Widget>.generate(_avatarPalettes.length, (
                    index,
                  ) {
                    final selected = index == widget.state.avatarIndex;
                    final palette = _avatarPalettes[index];
                    return InkWell(
                      onTap: () => widget.onAvatarChanged(index),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: palette,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF173B7A)
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _buildInitials(widget.state.fullName),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Update the details from your registration flow.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
          if (widget.state.message != null) ...[
            const SizedBox(height: 14),
            _Banner(
              message: widget.state.message!,
              color: const Color(0xFFEAF6F0),
              borderColor: const Color(0xFFB8E0CA),
              textColor: const Color(0xFF1E5B4A),
            ),
          ],
          if (widget.state.errorMessage != null) ...[
            const SizedBox(height: 14),
            _Banner(
              message: widget.state.errorMessage!,
              color: const Color(0xFFFDECEC),
              borderColor: const Color(0xFFE7A1A1),
              textColor: const Color(0xFF8A3D3D),
            ),
          ],
          const SizedBox(height: 18),
          _ProfileField(
            controller: _fullNameController,
            label: 'Name',
            icon: Icons.person_outline,
            onChanged: widget.onFullNameChanged,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _nicknameController,
            label: 'Nickname',
            icon: Icons.tag_faces_outlined,
            onChanged: widget.onNicknameChanged,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _occupationController,
            label: 'Occupation',
            icon: Icons.work_outline,
            onChanged: widget.onOccupationChanged,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _emailController,
            label: 'Email',
            icon: Icons.alternate_email,
            onChanged: widget.onEmailChanged,
          ),
          const SizedBox(height: 14),
          _ProfileField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            onChanged: widget.onPhoneChanged,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.state.isSaving ? null : widget.onSaveClick,
              child: const Text('Save Profile'),
            ),
          ),
          if (widget.state.isSaving) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

String _buildInitials(String fullName) {
  final parts = fullName
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

class _EditableAvatar extends StatelessWidget {
  const _EditableAvatar({
    required this.initials,
    required this.avatarIndex,
    required this.onTap,
  });

  final String initials;
  final int avatarIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            gradient: LinearGradient(
              colors: palette,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22333D4B),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
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
                    Icons.edit_rounded,
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
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF6F8FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
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
