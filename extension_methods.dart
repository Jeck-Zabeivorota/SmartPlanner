extension ExList<T> on List<T> {
  List<T> insertSepars(T separator) {
    List<T> newList = <T>[];
    if (isEmpty) return newList;

    for (int i = 0; i < length - 1; i++) {
      newList.add(this[i]);
      newList.add(separator);
    }
    newList.add(last);

    return newList;
  }

  int count(bool Function(T) predicate) {
    int count = 0;
    for (T item in this) {
      if (predicate(item)) count++;
    }
    return count;
  }
}

extension ExString on String {
  String insert(int index, String text) {
    if (index < 0 || index >= length) throw Exception('index out of range');
    return '${substring(0, index)}$text${substring(index)}';
  }
}

extension ExDouble on double {
  /// Returns a value with the number of decimal places trimmed to the number [number]
  double toFixed(int number) => double.parse(toStringAsFixed(number));

  /// Convert to amount format string
  /// ```
  /// double number = 10000000.5365;
  /// print(number.toAmountString()); // +10 000 000.53
  /// print(number.toAmountString(latestNumbers = 3, addPlus = false)); // 10 000 000.536
  /// ```
  String toAmountString({int latestNumbers = 2, bool addPlus = true}) {
    if (this == 0) addPlus = false;
    String amountStr = toStringAsFixed(latestNumbers);

    final startIdx = amountStr[0] == '-' ? 1 : 0;
    final endIdx = amountStr.lastIndexOf('.') - 3;

    for (int i = endIdx; i > startIdx; i -= 3) {
      amountStr = amountStr.insert(i, ' ');
    }

    if (addPlus && amountStr[0] != '-') amountStr = '+$amountStr';
    return amountStr;
  }
}

extension ExDateTime on DateTime {
  /// Convert to format string
  ///
  /// Designations:
  /// 'ss' - seconds, 'mm' - minutes, 'hh' - hours, 'dd' - days, 'MM' - mounths, 'yyyy' - years.
  /// ```
  /// DateTime date = DateTime(1950, 2, 6);
  /// print(date.toStringFormat('dd.MM.yyyy')); // 06.02.1950
  /// ```
  String toStringFormat(String format) {
    String intToString(int value) => value > 9 ? value.toString() : '0$value';
    format = format.replaceAll('ss', intToString(second));
    format = format.replaceAll('mm', intToString(minute));
    format = format.replaceAll('hh', intToString(hour));
    format = format.replaceAll('dd', intToString(day));
    format = format.replaceAll('MM', intToString(month));
    format = format.replaceAll('yyyy', intToString(year));
    return format;
  }

  bool operator >(DateTime date) => isAfter(date);
  bool operator <(DateTime date) => isBefore(date);
  bool operator >=(DateTime date) => isAfter(date) || this == date;
  bool operator <=(DateTime date) => isBefore(date) || this == date;
}

extension ExMap<K, V> on Map<K, V> {
  K getKey(V value) => keys.firstWhere((key) => this[key] == value);
}
