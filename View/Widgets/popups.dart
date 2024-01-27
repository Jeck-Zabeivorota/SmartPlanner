import 'package:flutter/material.dart';
import '../colors.dart';
import '../elements.dart';
import 'date_field.dart';

enum MessageIcon { info, error, question, warning }

abstract class Popups {
  static const Map<MessageIcon, Icon> _icons = {
    MessageIcon.info: Icon(Icons.info, color: Colors.blue),
    MessageIcon.error: Icon(Icons.error, color: Colors.red),
    MessageIcon.question: Icon(Icons.question_mark, color: Colors.green),
    MessageIcon.warning: Icon(Icons.warning, color: Colors.orangeAccent)
  };

  static Widget _createAction({
    required void Function() onPressed,
    required String text,
    Color? color,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyles.flatButton(
        side: BorderSide(color: ViewColors.second.withOpacity(0.7)),
        borderRadius: BorderRadius.zero,
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(text, style: TextStyles.text(color: color)),
    );
  }

  static Widget _createContaiter({
    required List<Widget> children,
    required List<Widget> actions,
  }) {
    final List<Widget> widgets = [const SizedBox(height: 20)];
    widgets.addAll(children);
    widgets.add(const SizedBox(height: 20));
    widgets.add(Row(
      children: actions.map((action) => Expanded(child: action)).toList(),
    ));

    return Center(
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: 300,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
                color: ViewColors.background,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: ViewColors.shadow,
                    offset: const Offset(0, 20),
                    blurRadius: 20,
                  ),
                ]),
            child: Column(mainAxisSize: MainAxisSize.min, children: widgets),
          ),
        ),
      ),
    );
  }

  static Future<String?> showMessage(
    BuildContext context, {
    String? title,
    required String content,
    MessageIcon? icon,
    List<String> actions = const ['OK'],
  }) {
    List<Widget> widgets = [];
    if (icon != null) {
      widgets.add(_icons[icon]!);
      widgets.add(const SizedBox(height: 10));
    }
    if (title != null) {
      widgets.add(Text(title, style: TextStyles.capture()));
      widgets.add(const SizedBox(height: 5));
    }
    widgets.add(Text(content, style: TextStyles.text()));

    return showDialog<String?>(
      context: context,
      builder: (context) => _createContaiter(
        children: widgets,
        actions: actions
            .map((action) => _createAction(
                  onPressed: () => Navigator.pop(context, action),
                  text: action,
                ))
            .toList(),
      ),
    );
  }

  static Future<String?> getText(
    BuildContext context, {
    required String title,
    String? content,
  }) {
    final controller = TextEditingController(text: content);

    List<Widget> widgets = [Text(title, style: TextStyles.capture())];
    widgets.add(const SizedBox(height: 10));
    widgets.add(TextField(
      controller: controller,
      minLines: 1,
      maxLines: 4,
      style: TextStyles.text(),
      decoration: InputDecorations.field(
        width: 250,
        borderRadius: BorderRadius.circular(10),
        padding: const EdgeInsets.all(10),
        outline: true,
      ),
    ));

    return showDialog<String?>(
      context: context,
      builder: (context) => _createContaiter(
        children: widgets,
        actions: [
          _createAction(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            text: 'Скасувати',
          ),
          _createAction(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context, controller.text);
            },
            color: ViewColors.accent,
            text: 'Ввести',
          ),
        ],
      ),
    );
  }

  static Future<DateTime?> getDate(
    BuildContext context, {
    String? title,
    required DateTime date,
    bool dayIsShow = true,
    bool monthIsShow = true,
    bool yearIsShow = true,
  }) {
    final controller = DateFieldController.fromDateTime(date);
    controller.dayFieldIsVisible = dayIsShow;
    controller.monthFieldIsVisible = monthIsShow;
    controller.yearFieldIsVisible = yearIsShow;

    List<Widget> widgets = [];
    if (title != null) {
      widgets.add(Text(title, style: TextStyles.capture()));
      widgets.add(const SizedBox(height: 10));
    }
    widgets.add(DateField(controller: controller));

    return showDialog<DateTime?>(
      context: context,
      builder: (context) => _createContaiter(
        children: widgets,
        actions: [
          _createAction(
            onPressed: () => Navigator.pop(context),
            text: 'Скасувати',
          ),
          _createAction(
            onPressed: () => Navigator.pop(context, controller.date),
            color: ViewColors.accent,
            text: 'Ввести',
          ),
        ],
      ),
    );
  }
}
