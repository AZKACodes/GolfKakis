import 'package:flutter/material.dart';

import '../viewmodel/profile_register_details_view_contract.dart';

class ProfileRegisterDetailsView extends StatefulWidget {
  const ProfileRegisterDetailsView({
    required this.state,
    required this.onNameChanged,
    required this.onNicknameChanged,
    required this.onOccupationChanged,
    required this.onSubmitClick,
    super.key,
  });

  final ProfileRegisterDetailsViewState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onOccupationChanged;
  final VoidCallback onSubmitClick;

  @override
  State<ProfileRegisterDetailsView> createState() =>
      _ProfileRegisterDetailsViewState();
}

class _ProfileRegisterDetailsViewState
    extends State<ProfileRegisterDetailsView> {
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _occupationController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _nicknameController = TextEditingController(text: widget.state.nickname);
    _occupationController = TextEditingController(
      text: widget.state.occupation,
    );
  }

  @override
  void didUpdateWidget(covariant ProfileRegisterDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.state.name) {
      _nameController.text = widget.state.name;
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
    _nameController.dispose();
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
                      'Tell me about yourself',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is the last proof-of-concept step before we create a dummy account for ${widget.state.phoneNumber}.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    if (widget.state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDECEC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE7A1A1)),
                        ),
                        child: Text(
                          widget.state.errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8A3D3D),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      onChanged: widget.onNameChanged,
                      decoration: InputDecoration(
                        labelText: 'Name',
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.state.isSubmitting
                            ? null
                            : widget.onSubmitClick,
                        child: const Text('Complete Registration'),
                      ),
                    ),
                    if (widget.state.isSubmitting) ...[
                      const SizedBox(height: 14),
                      const LinearProgressIndicator(),
                    ],
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
