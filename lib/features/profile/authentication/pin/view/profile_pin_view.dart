import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../viewmodel/profile_pin_view_contract.dart';

class ProfilePinView extends StatefulWidget {
  const ProfilePinView({
    required this.state,
    required this.onPinChanged,
    required this.onConfirmPinChanged,
    required this.onForgotPinClick,
    super.key,
  });

  final ProfilePinViewState state;
  final ValueChanged<String> onPinChanged;
  final ValueChanged<String> onConfirmPinChanged;
  final VoidCallback onForgotPinClick;

  @override
  State<ProfilePinView> createState() => _ProfilePinViewState();
}

class _ProfilePinViewState extends State<ProfilePinView> {
  late final List<TextEditingController> _pinControllers;
  late final List<FocusNode> _pinFocusNodes;
  late final List<TextEditingController> _confirmPinControllers;
  late final List<FocusNode> _confirmPinFocusNodes;

  @override
  void initState() {
    super.initState();
    _pinControllers = _createControllers(widget.state.pin);
    _pinFocusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
    _confirmPinControllers = _createControllers(widget.state.confirmPin);
    _confirmPinFocusNodes = List<FocusNode>.generate(6, (_) => FocusNode());
  }

  @override
  void didUpdateWidget(covariant ProfilePinView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers(_pinControllers, widget.state.pin);
    _syncControllers(_confirmPinControllers, widget.state.confirmPin);
  }

  @override
  void dispose() {
    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final focusNode in _pinFocusNodes) {
      focusNode.dispose();
    }
    for (final controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (final focusNode in _confirmPinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  List<TextEditingController> _createControllers(String value) {
    return List<TextEditingController>.generate(6, (index) {
      final text = index < value.length ? value[index] : '';
      return TextEditingController(text: text);
    });
  }

  void _syncControllers(List<TextEditingController> controllers, String value) {
    for (var i = 0; i < controllers.length; i++) {
      final nextText = i < value.length ? value[i] : '';
      if (controllers[i].text != nextText) {
        controllers[i].text = nextText;
      }
    }
  }

  void _handlePinChanged(int index, String value) {
    _handleDigitsChanged(
      controllers: _pinControllers,
      focusNodes: _pinFocusNodes,
      index: index,
      value: value,
      onChanged: widget.onPinChanged,
    );
  }

  void _handleConfirmPinChanged(int index, String value) {
    _handleDigitsChanged(
      controllers: _confirmPinControllers,
      focusNodes: _confirmPinFocusNodes,
      index: index,
      value: value,
      onChanged: widget.onConfirmPinChanged,
    );
  }

  void _handleDigitsChanged({
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required int index,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    final sanitized = value.replaceAll(RegExp(r'[^0-9]'), '');
    final digit = sanitized.isEmpty ? '' : sanitized[0];
    if (controllers[index].text != digit) {
      controllers[index].text = digit;
    }

    onChanged(controllers.map((controller) => controller.text).join());

    if (digit.isNotEmpty && index < focusNodes.length - 1) {
      focusNodes[index + 1].requestFocus();
    }
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
                    Text(
                      widget.state.mode == ProfilePinMode.login
                          ? 'Enter app PIN'
                          : 'Create app PIN',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.state.mode == ProfilePinMode.login
                          ? 'Enter your 6-digit PIN to continue.'
                          : 'Enter and confirm a 6-digit PIN.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    if (widget.state.errorMessage != null) ...[
                      const SizedBox(height: 14),
                      _InlineBanner(message: widget.state.errorMessage!),
                    ],
                    const SizedBox(height: 18),
                    _PinBoxesField(
                      label: widget.state.mode == ProfilePinMode.login
                          ? '6-digit PIN'
                          : 'Enter 6-digit PIN',
                      controllers: _pinControllers,
                      focusNodes: _pinFocusNodes,
                      onDigitChanged: _handlePinChanged,
                    ),
                    if (widget.state.mode == ProfilePinMode.setup) ...[
                      const SizedBox(height: 14),
                      _PinBoxesField(
                        label: 'Confirm 6-digit PIN',
                        controllers: _confirmPinControllers,
                        focusNodes: _confirmPinFocusNodes,
                        onDigitChanged: _handleConfirmPinChanged,
                      ),
                    ],
                    if (widget.state.mode == ProfilePinMode.login &&
                        widget.state.hasOTPFallback) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: widget.onForgotPinClick,
                          child: const Text('Forgot Pin?'),
                        ),
                      ),
                    ],
                    if (widget.state.isSubmitting) ...[
                      const SizedBox(height: 18),
                      const Center(child: CircularProgressIndicator()),
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

class _PinBoxesField extends StatelessWidget {
  const _PinBoxesField({
    required this.label,
    required this.controllers,
    required this.focusNodes,
    required this.onDigitChanged,
  });

  final String label;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onDigitChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.black54,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List<Widget>.generate(6, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 5 ? 0 : 8),
                child: TextField(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical.center,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) => onDigitChanged(index, value),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(height: 58),
                    filled: true,
                    fillColor: const Color(0xFFF6F8FC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
