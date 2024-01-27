import 'package:flutter/material.dart';
import '../../extension_methods.dart';
import '../../Instruments/date_duration.dart';
import '../../Database/Models/item_model.dart';
import '../colors.dart';
import '../elements.dart';
import '../Widgets/popups.dart';

class CalendarController {
  late int _month, _year;
  DateTime selectedDate;
  List<ItemModel> items = [];

  int get month => _month;
  int get year => _year;

  void setDate(DateTime date) {
    _year = date.year;
    _month = date.month;
  }

  CalendarController({required this.selectedDate}) {
    _year = selectedDate.year;
    _month = selectedDate.month;
  }
}

class Calendar extends StatefulWidget {
  final void Function() onSelectDay;
  final CalendarController controller;
  final List<Widget> panelActions;

  const Calendar({
    super.key,
    required this.onSelectDay,
    required this.controller,
    required this.panelActions,
  });

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  static const Map<int, String> monthsDict = {
    1: 'Січень',
    2: 'Лютий',
    3: 'Березень',
    4: 'Квітень',
    5: 'Травень',
    6: 'Червень',
    7: 'Липень',
    8: 'Серпень',
    9: 'Вересень',
    10: 'Жовтень',
    11: 'Листопад',
    12: 'Грудень',
  };

  final nowDate = DateTime.now();
  final numberSize = 25.0;

  void _onSelectDay(int day) {
    CalendarController control = widget.controller;
    setState(() {
      control.selectedDate = DateTime(control.year, control.month, day);
      widget.onSelectDay();
    });
  }

  void _offsetMonth(int offset) {
    CalendarController control = widget.controller;
    DateTime date = DateTime(control.year, control.month);
    setState(() {
      control.setDate(offset >= 0
          ? DateDuration(months: offset).addTo(date)
          : DateDuration(months: -offset).removeFrom(date));
    });
  }

  void _showYearDialog() async {
    CalendarController control = widget.controller;

    DateTime? date = await Popups.getDate(
      context,
      date: DateTime(control._year),
      dayIsShow: false,
      monthIsShow: false,
    );

    if (date != null && date.year != control.year) {
      setState(() => control.setDate(DateTime(date.year, control.month)));
    }
  }

  Widget _createYearAndPanel() {
    return Templates.rowPanel(
      first: TextButton(
        onPressed: _showYearDialog,
        style: ButtonStyles.flatButton(borderRadius: BorderRadius.circular(5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.controller.year.toString(),
              style: TextStyles.text(fontSize: 24, isBold: true),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: ViewColors.text,
            ),
          ],
        ),
      ),
      actions: widget.panelActions,
    );
  }

  Widget _createMonthsPanel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Templates.iconButton(
          onPressed: () => _offsetMonth(-1),
          iconSize: numberSize,
          borderRadius: BorderRadius.circular(20),
          icon: Icons.keyboard_arrow_left_rounded,
        ),
        Text(
          monthsDict[widget.controller.month]!,
          style: TextStyles.capture(),
        ),
        Templates.iconButton(
          onPressed: () => _offsetMonth(1),
          iconSize: numberSize,
          borderRadius: BorderRadius.circular(20),
          icon: Icons.keyboard_arrow_right_rounded,
        ),
      ],
    );
  }

  Widget _createNumberIndicators(
    DateTime date,
    List<ItemModel> items,
    bool isToday,
  ) {
    bool isHoliday = false, isBirthday = false, isOther = false;

    for (ItemModel item in items) {
      if (item.datetime.isToday(date)) {
        if (!isHoliday && item.category == Category.holiday) {
          isHoliday = true;
        } else if (!isBirthday && item.category == Category.birthday) {
          isBirthday = true;
        } else if (!isOther) {
          isOther = true;
        }
      }
    }

    Container createIndicator(Color color) => Container(
          width: numberSize / 8,
          height: numberSize / 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        );

    List<Widget> widgets = [];
    if (isBirthday) widgets.add(createIndicator(Colors.orange));
    if (isHoliday) widgets.add(createIndicator(Colors.purpleAccent));
    if (isOther) widgets.add(createIndicator(ViewColors.accent));
    SizedBox margin = SizedBox(height: numberSize / 8, width: numberSize / 10);

    Row indicators = Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets.isNotEmpty ? widgets.insertSepars(margin) : [margin],
    );

    return isToday && widgets.isNotEmpty
        ? Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(numberSize / 10),
              border: Border.all(
                width: 1.5,
                color: ViewColors.background2,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
              color: ViewColors.background2,
            ),
            child: indicators,
          )
        : indicators;
  }

  Widget _createNumber(
    int number,
    List<ItemModel> items, {
    bool isThisMonthNumber = true,
  }) {
    var control = widget.controller;
    DateTime date = DateTime(control.year, control.month, number);

    bool isToday =
        isThisMonthNumber && DateDuration.compareDates(date, nowDate) == 0;
    bool isSelected = isThisMonthNumber &&
        DateDuration.compareDates(date, control.selectedDate) == 0;

    BoxShadow? shadow = isToday || isSelected
        ? BoxShadow(
            color: isToday
                ? ViewColors.accent.withAlpha(80)
                : ViewColors.text.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        : null;

    return Padding(
      padding: EdgeInsets.all(numberSize / 4),
      child: Templates.sensor(
        onTap: () => isThisMonthNumber
            ? _onSelectDay(number)
            : _offsetMonth(number > 15 ? -1 : 1),
        child: Container(
          alignment: Alignment.center,
          height: numberSize * 1.1,
          width: numberSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? ViewColors.accent : null,
            border: isSelected
                ? Border.all(
                    color: ViewColors.text2.withAlpha(80),
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                : null,
            boxShadow: shadow != null ? [shadow] : const [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                number.toString(),
                style: TextStyles.capture(
                  color: isToday
                      ? Colors.white
                      : isThisMonthNumber
                          ? null
                          : ViewColors.text2.withAlpha(200),
                ),
              ),
              isThisMonthNumber
                  ? _createNumberIndicators(date, items, isToday)
                  : SizedBox(height: numberSize / 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createNumbers() {
    List<ItemModel> items = widget.controller.items;
    int month = widget.controller.month, year = widget.controller.year;

    // week
    List<String> weekDaysStr = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];

    Row weekDays = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: weekDaysStr
          .map((weekday) => Container(
                alignment: Alignment.center,
                height: numberSize * 1.5,
                width: numberSize * 1.5,
                child: Text(weekday, style: TextStyles.capture()),
              ))
          .toList(),
    );
    List<Widget> content = [weekDays, SizedBox(height: numberSize / 2)];

    // numbers
    DateTime monthEarlyDate =
        DateDuration(months: 1).removeFrom(DateTime(year, month));
    int daysInPreMount =
        DateDuration.daysInMonth(monthEarlyDate.month, monthEarlyDate.year);
    int daysInMount = DateDuration.daysInMonth(month, year);
    int weekday = DateTime(year, month, 1).weekday;
    List<Widget> numbers = [];

    // preview month numbers
    for (int i = daysInPreMount - weekday + 2; i <= daysInPreMount; i++) {
      numbers.add(_createNumber(i, items, isThisMonthNumber: false));
    }

    // this month numbers
    for (int i = 1; i <= daysInMount; i++) {
      numbers.add(_createNumber(i, items));
    }

    // next month numbers
    int nextNumbers = 7 - numbers.length % 7;
    for (int i = 1; i <= nextNumbers; i++) {
      numbers.add(_createNumber(i, items, isThisMonthNumber: false));
    }

    for (int i = 0; i < numbers.length; i += 7) {
      content.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: numbers.getRange(i, i + 7).toList(),
      ));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: content,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _createYearAndPanel(),
        const SizedBox(height: 40),
        _createMonthsPanel(),
        const SizedBox(height: 15),
        _createNumbers(),
      ],
    );
  }
}
