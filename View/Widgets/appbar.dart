import 'package:flutter/material.dart';
import 'dart:io';
import '../colors.dart';

class Appbar extends StatelessWidget {
  final Widget? first, title;
  final List<Widget>? actions;

  const Appbar({super.key, this.first, this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [];

    if (first != null) widgets.add(first!);
    if (title != null) widgets.add(title!);
    if (actions != null) {
      widgets.add(Row(mainAxisSize: MainAxisSize.min, children: actions!));
    }

    return Container(
      decoration: BoxDecoration(
        color: ViewColors.background,
        border: Border(
          bottom: BorderSide(color: ViewColors.second.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: ViewColors.shadow,
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 7,
        right: 7,
        bottom: 7,
        top: Platform.isAndroid || Platform.isIOS ? 32 : 7,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      ),
    );
  }
}
