import 'package:flutter/material.dart';
import 'colors.dart';

abstract class TextStyles {
  static TextStyle text(
          {Color? color,
          double? fontSize,
          String? fontFamily,
          bool isBold = false}) =>
      TextStyle(
        color: color ?? ViewColors.text,
        fontSize: fontSize ?? 14,
        fontFamily: fontFamily ?? 'Ubuntu',
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        decoration: TextDecoration.none,
      );

  static TextStyle second({Color? color}) => text(
        color: color ?? ViewColors.text2,
        fontSize: 11,
      );

  static TextStyle capture({Color? color}) => text(
        color: color,
        fontSize: 16,
        isBold: true,
      );
}

abstract class ButtonStyles {
  static ButtonStyle elevatedButton({
    Color? backgroundColor,
    Color? overlayColor,
    double? elevation,
    Color? shadowColor,
    BorderSide side = BorderSide.none,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) =>
      ButtonStyle(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return (overlayColor ?? ViewColors.background).withOpacity(0.1);
          }
          return Colors.white.withAlpha(1);
        }),
        backgroundColor:
            MaterialStateProperty.all(backgroundColor ?? ViewColors.accent),
        elevation: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) return 0;
          return elevation ?? 5;
        }),
        shadowColor: MaterialStateProperty.all(
            shadowColor ?? ViewColors.accent.withOpacity(0.5)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            side: side,
            borderRadius: borderRadius ?? BorderRadius.circular(10),
          ),
        ),
        padding: padding == null ? null : MaterialStateProperty.all(padding),
        minimumSize: MaterialStateProperty.all(const Size(0, 0)),
      );

  static ButtonStyle flatButton({
    Color? color,
    BorderSide side = BorderSide.none,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) =>
      ButtonStyle(
        mouseCursor: MaterialStateProperty.all(SystemMouseCursors.click),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return (color ?? ViewColors.text2).withOpacity(0.03);
          }
          return Colors.white.withAlpha(1);
        }),
        backgroundColor: MaterialStateProperty.all(Colors.transparent),
        foregroundColor: MaterialStateProperty.all(color ?? ViewColors.text2),
        elevation: MaterialStateProperty.all(0),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            side: side,
            borderRadius:
                borderRadius ?? const BorderRadius.all(Radius.circular(5)),
          ),
        ),
        padding: padding == null ? null : MaterialStateProperty.all(padding),
        minimumSize: MaterialStateProperty.all(const Size(0, 0)),
      );
}

abstract class InputDecorations {
  static InputDecoration field({
    Widget? prefix,
    Widget? suffix,
    double? width,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    bool outline = false,
  }) {
    final enabledBorderSide = BorderSide(color: ViewColors.text2),
        focusedBorderSide = BorderSide(color: ViewColors.text2, width: 2),
        errorBorderSide = const BorderSide(color: Colors.red);

    final Function borderConstructor =
        outline ? OutlineInputBorder.new : UnderlineInputBorder.new;

    return InputDecoration(
      isDense: true,
      enabledBorder: borderConstructor(
        borderSide: enabledBorderSide,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      focusedBorder: borderConstructor(
        borderSide: focusedBorderSide,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      errorBorder: borderConstructor(borderSide: errorBorderSide),
      constraints: BoxConstraints(maxWidth: width ?? double.infinity),
      prefixStyle: TextStyles.text(color: ViewColors.text2),
      suffixStyle: TextStyles.text(color: ViewColors.text2),
      prefix: prefix,
      suffix: suffix,
      contentPadding: padding,
    );
  }
}

abstract class Templates {
  static TextButton iconButton({
    required void Function()? onPressed,
    required IconData? icon,
    double iconSize = 20,
    Color? iconColor,
    Color? color,
    EdgeInsetsGeometry? padding,
    BorderSide side = BorderSide.none,
    BorderRadius? borderRadius,
  }) =>
      TextButton(
        onPressed: onPressed,
        style: ButtonStyles.flatButton(
          color: color,
          side: side,
          borderRadius: borderRadius,
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        ),
        child: Icon(icon, size: iconSize, color: iconColor ?? ViewColors.text),
      );

  static Widget field({
    required String label,
    required Widget child,
    TextStyle? style,
    double indent = 5,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: style ?? TextStyles.second()),
          SizedBox(height: indent),
          child,
        ],
      );

  static Widget dismissible({
    required int id,
    required Future<bool?> Function(DismissDirection)? onDismiss,
    required Widget child,
  }) =>
      Dismissible(
        key: ValueKey<int>(id),
        confirmDismiss: onDismiss,
        background: Container(
          color: Colors.red,
          child: const Row(children: [
            SizedBox(width: 20),
            Icon(Icons.delete, color: Colors.white, size: 25),
            Expanded(child: SizedBox()),
            Icon(Icons.delete, color: Colors.white, size: 25),
            SizedBox(width: 20),
          ]),
        ),
        child: child,
      );

  static Widget sensor({required void Function() onTap, required Widget child}) =>
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(onTap: onTap, child: child),
      );

  static Widget rowPanel({
    required Widget first,
    required List<Widget> actions,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          first,
          Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          ),
        ],
      );
}
