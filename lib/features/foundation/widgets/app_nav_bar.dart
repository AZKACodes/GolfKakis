import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget implements PreferredSizeWidget {
  const AppNavBar({
    super.key,
    this.title,
    this.titleWidget,
    this.onBackPressed,
    this.showBackButton = true,
    this.actions = const <Widget>[],
    this.centerTitle = false,
    this.bottom,
  }) : assert(title != null || titleWidget != null);

  final String? title;
  final Widget? titleWidget;
  final VoidCallback? onBackPressed;
  final bool showBackButton;
  final List<Widget> actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              onPressed:
                  onBackPressed ?? () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            )
          : null,
      title: titleWidget ?? Text(title!),
      actions: actions,
      bottom: bottom,
    );
  }
}
