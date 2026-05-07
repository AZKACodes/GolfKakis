import 'package:flutter/material.dart';

class GolfKakisSearchbar extends StatelessWidget {
  const GolfKakisSearchbar({
    required this.initialValue,
    required this.onChanged,
    this.hintText = 'Search',
    this.trailing,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GolfKakisSearchField(
            initialValue: initialValue,
            onChanged: onChanged,
            hintText: hintText,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class _GolfKakisSearchField extends StatefulWidget {
  const _GolfKakisSearchField({
    required this.initialValue,
    required this.onChanged,
    required this.hintText,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String hintText;

  @override
  State<_GolfKakisSearchField> createState() => _GolfKakisSearchFieldState();
}

class _GolfKakisSearchFieldState extends State<_GolfKakisSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(covariant _GolfKakisSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialValue,
        selection: TextSelection.collapsed(offset: widget.initialValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7E4)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE1E7E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF173B7A), width: 1.2),
        ),
      ),
    );
  }
}
