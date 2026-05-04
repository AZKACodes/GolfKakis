import 'package:flutter/material.dart';

import '../viewmodel/profile_register_details_view_contract.dart';

class ProfileRegisterDetailsView extends StatefulWidget {
  const ProfileRegisterDetailsView({
    required this.state,
    required this.onFullNameChanged,
    required this.onNicknameChanged,
    required this.onOccupationChanged,
    required this.onContinueClick,
    required this.onSkipClick,
    super.key,
  });

  final ProfileRegisterDetailsViewState state;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onOccupationChanged;
  final VoidCallback onContinueClick;
  final VoidCallback onSkipClick;

  @override
  State<ProfileRegisterDetailsView> createState() =>
      _ProfileRegisterDetailsViewState();
}

class _ProfileRegisterDetailsViewState
    extends State<ProfileRegisterDetailsView> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _occupationController;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.state.fullName);
    _nicknameController = TextEditingController(text: widget.state.nickname);
    _occupationController = TextEditingController(
      text: widget.state.occupation,
    );
  }

  @override
  void didUpdateWidget(covariant ProfileRegisterDetailsView oldWidget) {
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
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFFBF4), Color(0xFFF2F7FF), Color(0xFFF0FCF6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A2F7BFF),
                      blurRadius: 30,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tell me more about yourself',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can skip this for now and update it later from Edit Profile.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _fullNameController,
                      textInputAction: TextInputAction.next,
                      onChanged: widget.onFullNameChanged,
                      decoration: InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: const Icon(Icons.person_outline),
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _nicknameController,
                      textInputAction: TextInputAction.next,
                      onChanged: widget.onNicknameChanged,
                      decoration: InputDecoration(
                        labelText: 'Nickname',
                        prefixIcon: const Icon(Icons.tag_faces_outlined),
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (widget.state.requiresOccupation) ...[
                      TextField(
                        controller: _occupationController,
                        textInputAction: TextInputAction.done,
                        onChanged: widget.onOccupationChanged,
                        decoration: InputDecoration(
                          labelText: 'Occupation',
                          prefixIcon: const Icon(Icons.work_outline),
                          filled: true,
                          fillColor: const Color(0xFFF6F8FC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ] else
                      const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onSkipClick,
                            child: const Text('Skip for now'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: widget.onContinueClick,
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
