import 'package:flutter/material.dart';
import '../colors.dart';
import '../elements.dart';

class CheckBoxController {
  bool isCheck;
  Color? activeColor;

  CheckBoxController({this.isCheck = false, this.activeColor});
}

class CheckBox extends StatefulWidget {
  final CheckBoxController controller;
  final void Function(bool)? onChange;
  final double size;
  final BoxBorder? border;

  const CheckBox({
    super.key,
    required this.controller,
    this.onChange,
    this.size = 15,
    this.border,
  });

  @override
  State<CheckBox> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  @override
  Widget build(BuildContext context) {
    final isCheck = widget.controller.isCheck;
    final color = widget.controller.activeColor ?? ViewColors.accent;

    return Templates.sensor(
      onTap: () => setState(() {
        widget.controller.isCheck = !isCheck;
        if (widget.onChange != null) widget.onChange!(!isCheck);
      }),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: isCheck ? color : ViewColors.second.withAlpha(100),
          shape: BoxShape.circle,
          border: widget.border ??
              Border.all(
                color: isCheck ? color : ViewColors.text.withAlpha(50),
              ),
          boxShadow: isCheck
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: isCheck
            ? Icon(Icons.check, color: Colors.white, size: widget.size * 0.66)
            : null,
      ),
    );
  }
}
