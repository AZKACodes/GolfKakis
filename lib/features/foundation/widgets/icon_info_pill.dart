import 'package:flutter/material.dart';

class IconInfoPill extends StatelessWidget {
  const IconInfoPill({
    required this.icon,
    required this.label,
    this.value,
    this.backgroundColor = const Color(0xDBFFFFFF),
    this.borderColor = const Color(0x14000000),
    this.foregroundColor = const Color(0xFF0D7A3A),
    this.textColor = const Color(0xFF0A1F1A),
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.borderRadius = 999,
    this.iconSize = 14,
    this.spacing = 6,
    this.expandContent = false,
    this.labelStyle,
    this.valueStyle,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color backgroundColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color textColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double spacing;
  final bool expandContent;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultLabelStyle = theme.textTheme.labelMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w700,
    );
    final defaultValueStyle = theme.textTheme.bodyMedium?.copyWith(
      color: textColor,
      fontWeight: FontWeight.w800,
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: expandContent ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: foregroundColor),
          SizedBox(width: spacing),
          if (expandContent)
            Expanded(
              child: _PillTextContent(
                label: label,
                value: value,
                labelStyle: labelStyle ?? defaultLabelStyle,
                valueStyle: valueStyle ?? defaultValueStyle,
              ),
            )
          else
            _PillTextContent(
              label: label,
              value: value,
              labelStyle: labelStyle ?? defaultLabelStyle,
              valueStyle: valueStyle ?? defaultValueStyle,
            ),
        ],
      ),
    );
  }
}

class _PillTextContent extends StatelessWidget {
  const _PillTextContent({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String? value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) {
      return Text(label, style: labelStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: labelStyle,
        ),
        const SizedBox(height: 2),
        Text(
          value!,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: valueStyle,
        ),
      ],
    );
  }
}
