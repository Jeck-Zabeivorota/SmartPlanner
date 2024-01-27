class DateDuration {
  static const Map<int, String> monthsDict = {
    1: 'Січня',
    2: 'Лютого',
    3: 'Березня',
    4: 'Квітня',
    5: 'Травня',
    6: 'Червня',
    7: 'Липня',
    8: 'Серпня',
    9: 'Вересня',
    10: 'Жовтня',
    11: 'Листопада',
    12: 'Грудня',
  };

  late int days, months, years;

  bool get isNullPeriod => days == 0 && months == 0 && years == 0;

  static int daysInMonth(int month, int year) {
    DateTime d1 = DateTime(year, month);
    month++;
    if (month == 13) {
      month = 1;
      year++;
    }
    DateTime d2 = DateTime(year, month);
    return d2.difference(d1).inDays;
  }

  static int compareDates(DateTime date1, DateTime date2) {
    if (date1.year > date2.year) return -1;
    if (date1.year < date2.year) return 1;

    if (date1.month > date2.month) return -1;
    if (date1.month < date2.month) return 1;

    if (date1.day > date2.day) return -1;
    if (date1.day < date2.day) return 1;

    return 0;
  }

  static String dateToString(DateTime date, {DateTime? nowDate}) {
    if (nowDate != null &&
        date.year == nowDate.year &&
        date.month == nowDate.month) {
      int difference = date.day - nowDate.day;
      if (difference == -1) return 'Вчора';
      if (difference == 0) return 'Сьогодні';
      if (difference == 1) return 'Завтра';
    }
    return '${date.day} ${monthsDict[date.month]} - ${date.year}';
  }

  DateTime addTo(DateTime date) {
    int newYear = date.year + years + months ~/ 12;
    int newMonth = date.month + months % 12;
    if (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }

    int maxDay = daysInMonth(newMonth, newYear);
    int newDay = date.day <= maxDay ? date.day : maxDay;

    return DateTime(newYear, newMonth, newDay).add(Duration(days: days));
  }

  DateTime removeFrom(DateTime date) {
    int newYear = date.year - years - months ~/ 12;
    int newMonth = date.month - months % 12;
    if (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    int maxDay = daysInMonth(newMonth, newYear);
    int newDay = date.day <= maxDay ? date.day : maxDay;

    return DateTime(newYear, newMonth, newDay).subtract(Duration(days: days));
  }

  @override
  String toString() => '$days;$months;$years';

  DateDuration.fromString(String string) {
    List<int> data = string.split(';').map((s) => int.parse(s)).toList();
    days = data[0];
    months = data[1];
    years = data[2];
  }

  DateDuration({
    this.days = 0,
    this.months = 0,
    this.years = 0,
  });
}
