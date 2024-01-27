import 'package:flutter/material.dart';
import '../colors.dart';
import '../elements.dart';
import '../../Database/Models/item_model.dart';

class Item extends StatelessWidget {
  static const Map<Repead, String> _repeadDict = {
    Repead.once: 'один раз',
    Repead.day: 'кожного дня',
    Repead.week: 'кожного тижня',
    Repead.month: 'кожен місяць',
    Repead.year: 'кожного року',
  };

  final ItemModel model;
  final void Function() onPressed;
  final Future<bool?> Function(DismissDirection)? onDismiss;

  const Item({
    super.key,
    required this.onPressed,
    required this.onDismiss,
    required this.model,
  });

  String _getTimeLeft() {
    DateTime now = DateTime.now(), date = model.datetime.nextDateTime;

    if (date.isBefore(now)) return '(Минуло)';

    Duration delta = date.difference(now);

    if (delta.inDays >= 30) return '(через ${delta.inDays ~/ 30 + 1} місяців)';
    if (delta.inDays >= 1) return '(через ${delta.inDays + 1} днів)';
    if (model.isHolidayOrBirthday &&
        now.month == date.month &&
        now.day == date.day) return '(сьогодні)';
    if (delta.inHours >= 1) return '(через ${delta.inHours + 1} годин)';
    if (delta.inMinutes >= 1) return '(через ${delta.inMinutes + 1} хвилин)';
    return '(через 1 хвилин)';
  }

  Widget _createTime() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ViewColors.second,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 20,
      width: 50,
      child: Text(model.datetime.time, style: TextStyles.text()),
    );
  }

  Widget _createPriorityIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 5),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: priotityColors[model.priority],
          boxShadow: [
            BoxShadow(
              color: priotityColors[model.priority]!.withOpacity(0.5),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _createRegularContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _createTime(),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(model.title, style: TextStyles.text()),
              const SizedBox(height: 3),
              Text(
                '${_getTimeLeft()} · ${_repeadDict[model.datetime.repead]}',
                style: TextStyles.second(),
              ),
            ],
          ),
        ),
        _createPriorityIndicator(),
      ],
    );
  }

  Widget _createHolydayContent(bool isBirthday) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: isBirthday ? Colors.orange[600] : Colors.purple,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isBirthday ? Colors.orange : Colors.purple)
                    .withOpacity(0.2),
                offset: const Offset(0, 5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(
            isBirthday ? Icons.cake_rounded : Icons.star_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.title, style: TextStyles.text()),
            const SizedBox(height: 3),
            Text(_getTimeLeft(), style: TextStyles.second()),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Templates.dismissible(
      id: model.id!,
      onDismiss: onDismiss,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyles.flatButton(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          child: model.category == Category.holiday ||
                  model.category == Category.birthday
              ? _createHolydayContent(model.category == Category.birthday)
              : _createRegularContent(),
        ),
      ),
    );
  }
}
