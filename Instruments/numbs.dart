abstract class Numbs {
  static double avr(List<num> numbs) {
    if (numbs.isEmpty) throw Exception('numbs is empty');
    num sum = 0;

    for (num numb in numbs) {
      sum += numb;
    }

    return sum / numbs.length;
  }

  static T _maxOrMin<T extends num>(List<T> numbs, bool isMax) {
    if (numbs.isEmpty) throw Exception('numbs is empty');
    T value = numbs[0];

    for (T numb in numbs) {
      if (isMax ? numb > value : numb < value) value = numb;
    }

    return value;
  }

  static T max<T extends num>(List<T> numbs) => _maxOrMin(numbs, true);
  static T min<T extends num>(List<T> numbs) => _maxOrMin(numbs, false);

  static T _getValueByMaxOrMin<T>(List<T> items, num Function(T) selector,bool isMax) {
    if (items.isEmpty) throw Exception('"items" is empty');
    if (items.length == 1) return items[0];

    int index = 0;
    num value, controlValue = selector(items[0]);

    for (int i = 1; i < items.length; i++) {
      value = selector(items[i]);
      if (isMax ? value > controlValue : value < controlValue) {
        controlValue = value;
        index = i;
      }
    }

    return items[index];
  }

  static T getByMax<T>(List<T> values, num Function(T) selector) {
    return _getValueByMaxOrMin(values, selector, true);
  }

  static T getByMin<T>(List<T> values, num Function(T) selector) {
    return _getValueByMaxOrMin(values, selector, false);
  }
}
