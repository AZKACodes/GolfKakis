import 'package:flutter/material.dart';
import 'package:golf_kakis/features/foundation/widgets/input/golf_kakis_phone_number_input.dart';

import '../viewmodel/profile_register_view_contract.dart';

class ProfileRegisterView extends StatefulWidget {
  const ProfileRegisterView({
    required this.state,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onRegisterClick,
    super.key,
  });

  final ProfileRegisterViewState state;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;
  final VoidCallback onRegisterClick;

  @override
  State<ProfileRegisterView> createState() => _ProfileRegisterViewState();
}

class _ProfileRegisterViewState extends State<ProfileRegisterView> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
  }

  @override
  void didUpdateWidget(covariant ProfileRegisterView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_nameController.text != widget.state.name) {
      _nameController.text = widget.state.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2F7BFF), Color(0xFF35C7A5)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Create your account',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your name and phone number to get started.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    if (widget.state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _InlineBanner(message: widget.state.errorMessage!),
                    ],
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: widget.onNameChanged,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF6F8FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GolfKakisPhoneNumberInput(
                      phoneNumber: widget.state.phoneNumber,
                      onChanged: widget.onPhoneChanged,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: widget.state.canContinue
                            ? widget.onRegisterClick
                            : null,
                        child: widget.state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Register'),
                      ),
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

class _InlineBanner extends StatelessWidget {
  const _InlineBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7A1A1)),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF8A3D3D),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
