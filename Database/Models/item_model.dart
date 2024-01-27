import 'package:flutter/material.dart';
import '../i_model.dart';
import '../../Instruments/date_duration.dart';

enum Priority { high, medium, low, none }

enum Category { task, holiday, birthday, notification, meet }

enum Repead { once, day, week, month, year }

const Map<Priority, Color> priotityColors = {
  Priority.high: Colors.red,
  Priority.medium: Colors.orangeAccent,
  Priority.low: Colors.green,
};

class DateTimeData {
  late DateTime _datetime;
  late Repead repead;
  DateTime? _nextDateTime;

  set datetime(DateTime value) {
    _datetime = value;
    _nextDateTime = null;
  }

  int get hour => _datetime.hour;
  int get minute => _datetime.minute;

  String get time => '$hour:${minute < 10 ? "0$minute" : minute}';

  int _getDiapazoneFromCicle(int start, int end, int maxVauleOfCicle) {
    if (start < end) return end - start;
    if (start > end) return maxVauleOfCicle - (start - end);
    return 0;
  }

  DateTime get nextDateTime {
    if (_nextDateTime != null) return _nextDateTime!;

    DateTime now = DateTime.now();
    DateTime dt = DateTime(now.year, now.month, now.day, hour, minute);
    bool timeIsOver =
        now.hour > hour || (now.hour == hour && now.minute > minute);

    switch (repead) {
      case Repead.once:
        _nextDateTime = _datetime;
        break;

      case Repead.day:
        _nextDateTime = timeIsOver ? dt.add(const Duration(days: 1)) : dt;
        break;

      case Repead.week:
        int days = _getDiapazoneFromCicle(now.weekday, _datetime.weekday, 7);
        if (days < 0) return dt.add(Duration(days: days));
        _nextDateTime = timeIsOver ? dt.add(const Duration(days: 7)) : dt;
        break;

      case Repead.month:
        int maxDay = DateDuration.daysInMonth(now.month, now.year);
        int days = _getDiapazoneFromCicle(now.day, _datetime.day, maxDay);
        if (days > 0) return dt.add(Duration(days: days));
        _nextDateTime = timeIsOver ? DateDuration(months: 1).addTo(dt) : dt;
        break;

      case Repead.year:
        int months = _getDiapazoneFromCicle(now.month, _datetime.month, 12);
        if (months == 0 && now.day > _datetime.day) months = 11;

        int maxDay = DateDuration.daysInMonth(now.month, now.year);
        int days = _getDiapazoneFromCicle(now.day, _datetime.day, maxDay);
        if (months > 0 || days > 0) {
          return DateDuration(months: months, days: days).addTo(dt);
        }

        _nextDateTime = timeIsOver ? DateDuration(years: 1).addTo(dt) : dt;
    }

    return _nextDateTime!;
  }

  bool isToday(DateTime date) {
    switch (repead) {
      case Repead.once:
        return date.year == _datetime.year &&
            date.month == _datetime.month &&
            date.day == _datetime.day;

      case Repead.day:
        return true;

      case Repead.week:
        return date.weekday == _datetime.weekday;

      case Repead.month:
        return date.day == _datetime.day;

      case Repead.year:
        return date.month == _datetime.month && date.day == _datetime.day;
    }
  }

  Map<String, dynamic> toMap() => {
        'year': _datetime.year,
        'month': _datetime.month,
        'day': _datetime.day,
        'hour': _datetime.hour,
        'minute': _datetime.minute,
        'repead': repead.toString(),
      };

  DateTimeData.fromMap(Map<String, dynamic> map) {
    _datetime = DateTime(
        map['year'], map['month'], map['day'], map['hour'], map['minute']);

    repead = Repead.values.firstWhere((e) => e.toString() == map['repead']);
  }

  DateTimeData({required DateTime datetime, required this.repead}) {
    _datetime = datetime;
  }
}

class ItemModel implements IModel {
  @override
  int? id;
  late String title;
  late DateTimeData datetime;
  late Category category;
  late Priority priority;

  bool get isHolidayOrBirthday =>
      category == Category.holiday || category == Category.birthday;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'datetime': datetime.toMap(),
        'category': category.toString(),
        'priority': priority.toString(),
      };

  @override
  ItemModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    datetime = DateTimeData.fromMap(Map<String, dynamic>.from(map['datetime']));
    category = Category.values.firstWhere(
      (c) => c.toString() == map['category'],
    );
    priority = Priority.values.firstWhere(
      (p) => p.toString() == map['priority'],
    );
  }

  ItemModel({
    this.id,
    required this.title,
    required this.datetime,
    required this.category,
    this.priority = Priority.none,
  });
}
