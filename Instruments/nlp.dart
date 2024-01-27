import 'date_duration.dart';
import 'numbs.dart';
import '../Database/Models/item_model.dart';
import '../Database/Models/q_state_model.dart';

// Token

class RateWord {
  final String word;
  final double rate;
  const RateWord(this.word, this.rate);
}

abstract class Token {
  static const double thresholdSimilarity = 0.75;

  final String value;
  const Token({required this.value});

  @override
  String toString() => value;

  static bool isFindedAround({
    required String source,
    required int index,
    required int distance,
    required String pattern,
  }) {
    if (index < 0 || index >= source.length) return false;
    if (distance == 0) return source[index] == pattern;

    int start = index - distance, end = index + distance + 1;
    if (start < 0) start = 0;
    if (end > source.length) end = source.length;

    return source.substring(start, end).contains(pattern);
  }

  static double getSimilariry(String value1, String value2) {
    if (value1 == value2) return 1;
    if (value1.length == 1 || value2.length == 1) return 0;

    // count
    int differ = (value1.length - value2.length).abs();
    String minLenValue = value1.length < value2.length ? value1 : value2;
    String maxLenValue = minLenValue == value1 ? value2 : value1;

    // symbols
    int notFoundCount = differ, distance = (minLenValue.length * 0.3).toInt();

    for (int i = 0; i < minLenValue.length; i++) {
      if (!isFindedAround(
        source: minLenValue,
        index: i,
        distance: distance,
        pattern: maxLenValue[i],
      )) {
        notFoundCount++;
      }
    }

    if (notFoundCount == 0) return 1;
    return 1 - notFoundCount / minLenValue.length;
  }

  static RateWord? findSimilar(String value, List<String> values) {
    value = value.toLowerCase();
    String? word;
    double maxRate = thresholdSimilarity - 0.001;

    for (var v in values) {
      double rate = getSimilariry(v, value);
      if (rate > maxRate) {
        maxRate = rate;
        word = v;
      }
    }

    return word != null ? RateWord(word, maxRate) : null;
  }

  static List<String> split(String request) {
    if (request.isEmpty) return [];

    List<String> words = [];
    int start = 0, i = -1;

    while (++i < request.length) {
      if (_splitSymbols.contains(request[i])) {
        if (start < i) words.add(request.substring(start, i));
        if (request[i] != ' ') words.add(request[i]);
        start = i + 1;
      }
    }
    if (start < i) words.add(request.substring(start, i));

    return words;
  }
}

// Token lists

abstract class VariableToken<T> extends Token {
  final T? Function(List<String>) getVarValue;
  const VariableToken({required super.value, required this.getVarValue});
}

class AmplifierToken extends Token {
  final double priority;
  const AmplifierToken({required super.value, required this.priority});
}

class SeparatorToken extends AmplifierToken {
  final int direction;

  const SeparatorToken({
    required super.value,
    super.priority = 0,
    this.direction = 0,
  });
}

class CategoryToken extends Token {
  static const Map<Category, double> _categoryPriorities = {
    Category.task: 0.04,
    Category.meet: 0.03,
    Category.birthday: 0.02,
    Category.holiday: 0.01,
    Category.notification: 0,
  };

  final double priority;
  final Category category;

  CategoryToken({
    required super.value,
    required this.category,
  }) : priority = _categoryPriorities[category]!;
}

class DateToken extends VariableToken<DateTime> {
  const DateToken({required super.value, required super.getVarValue});
}

class TimeToken extends VariableToken<DateTime> {
  const TimeToken({required super.value, required super.getVarValue});
}

class RepeadToken extends VariableToken<Repead> {
  const RepeadToken({required super.value, required super.getVarValue});
}

// Dictionaries

const List<String> _splitSymbols = [',', '.', '!', '?', '(', ')', '-', ' '];

const List<String> _weekdays = [
  'понеділок',
  'вівторок',
  'середа',
  'четверг',
  "п'ятниця",
  'субота',
  'неділя',
];

const List<SeparatorToken> _separators = [
  SeparatorToken(value: 'але', priority: 0.1, direction: -1),
  SeparatorToken(value: 'бо', priority: 0.1, direction: -1),
  SeparatorToken(value: r'тому \oщо', priority: 0.1, direction: 1),
  SeparatorToken(value: 'так як', priority: 0.1, direction: -1),
  SeparatorToken(value: '.'),
  SeparatorToken(value: '!'),
  SeparatorToken(value: '?'),
];

const List<AmplifierToken> _amplifiers = [
  AmplifierToken(value: 'нагадай', priority: 0.3),
  AmplifierToken(value: 'треба', priority: 0.3),
  AmplifierToken(value: 'потрібно', priority: 0.3),
  AmplifierToken(value: 'створи', priority: 0.3),
  AmplifierToken(value: 'запиши', priority: 0.3),
  AmplifierToken(value: 'запиши', priority: 0.3),
  AmplifierToken(value: "обов'язково", priority: 0.3),
];

final List<CategoryToken> _categories = [
  CategoryToken(value: 'юбілей', category: Category.birthday),
  CategoryToken(value: 'день народження', category: Category.birthday),
  CategoryToken(value: 'іменини', category: Category.birthday),
  //
  CategoryToken(value: 'день', category: Category.holiday),
  CategoryToken(value: 'свято', category: Category.holiday),
  //
  CategoryToken(value: 'зустріч', category: Category.meet),
  CategoryToken(value: 'побачення', category: Category.meet),
  //
  CategoryToken(value: 'нагадай', category: Category.notification),
  CategoryToken(value: "напам'ятай", category: Category.notification),
  CategoryToken(value: 'нагадування', category: Category.notification),
  //
  CategoryToken(value: 'задачу', category: Category.task),
  CategoryToken(value: 'купити', category: Category.task),
  CategoryToken(value: 'зробити', category: Category.task),
  CategoryToken(value: 'забрати', category: Category.task),
  CategoryToken(value: 'створити', category: Category.task),
  CategoryToken(value: 'сходити', category: Category.task),
  CategoryToken(value: 'відвідати', category: Category.task),
  CategoryToken(value: 'провідати', category: Category.task),
  CategoryToken(value: 'заплатити', category: Category.task),
  CategoryToken(value: 'приготувати', category: Category.task),
  CategoryToken(value: "з'їздити", category: Category.task),
  CategoryToken(value: 'погуляти', category: Category.task),
  CategoryToken(value: 'підготуватися', category: Category.task),
];

final List<DateToken> _dates = [
  DateToken(
    value: 'завтра',
    getVarValue: (words) => DateTime.now().add(const Duration(days: 1)),
  ),
  DateToken(
    value: 'після завтра',
    getVarValue: (words) => DateTime.now().add(const Duration(days: 2)),
  ),
  DateToken(
    value:
        r'через \r\b\d+\b \lдень|днів|дні|дня|неділь|неділю|неділі|тиждень|тижднів|тиждні|місяць|місяців|рік|років|роки',
    getVarValue: (words) {
      DateTime now = DateTime.now();
      try {
        switch (words[2][0]) {
          case 'д':
            return now.add(Duration(days: int.parse(words[1])));
          case 'н':
            return DateDuration(days: int.parse(words[1]) * 7).addTo(now);
          case 'т':
            return DateDuration(days: int.parse(words[1]) * 7).addTo(now);
          case 'м':
            return DateDuration(months: int.parse(words[1])).addTo(now);
          default:
            return DateDuration(years: int.parse(words[1])).addTo(now);
        }
      } catch (e) {
        return null;
      }
    },
  ),
  DateToken(
    value: r'через \lдень|місяць|неділю|тиждень|рік',
    getVarValue: (words) {
      DateTime now = DateTime.now();
      switch (words[1][0]) {
        case 'д':
          return now.add(const Duration(days: 2));
        case 'н':
          return DateDuration(days: 7).addTo(now);
        case 'т':
          return DateDuration(days: 7).addTo(now);
        case 'м':
          return DateDuration(months: 2).addTo(now);
        default:
          return DateDuration(years: 2).addTo(now);
      }
    },
  ),
  DateToken(
    value: r'наступного|слідуючого \lдня|неділі|тиждня|місяця|року',
    getVarValue: (words) {
      DateTime now = DateTime.now();
      switch (words[1][0]) {
        case 'д':
          return now.add(const Duration(days: 1));
        case 'н':
          return DateDuration(days: 7).addTo(now);
        case 'т':
          return DateDuration(days: 7).addTo(now);
        case 'м':
          return DateDuration(months: 1).addTo(now);
        default:
          return DateDuration(years: 1).addTo(now);
      }
    },
  ),
  DateToken(
    value: r'\r\b\d+\b\.|-\b\d+\b\.|-\b\d+\b',
    getVarValue: (words) {
      List<int> numbers =
          words[0].split(RegExp(r'\.|-')).map((s) => int.parse(s)).toList();
      try {
        if (numbers[0] > 1000) {
          return DateTime(numbers[0], numbers[1], numbers[2]);
        }
        return DateTime(numbers[2], numbers[1], numbers[0]);
      } catch (e) {
        return null;
      }
    },
  ),
  DateToken(
    value: r'\r\b\d+\b \l' +
        DateDuration.monthsDict.values.join('|').toLowerCase() +
        r' \o\r\b\d+\b',
    getVarValue: (words) {
      var months = DateDuration.monthsDict;
      String prefix = words[1].substring(0, 2);
      try {
        return DateTime(
          words.length == 3 ? int.parse(words[2]) : DateTime.now().year,
          months.keys.firstWhere(
              (key) => months[key]!.toLowerCase().startsWith(prefix)),
          int.parse(words[0]),
        );
      } catch (e) {
        return null;
      }
    },
  ),
  DateToken(
    value: r'\lв|наступного|наступної \l' + _weekdays.join('|'),
    getVarValue: (words) {
      DateTime now = DateTime.now();
      int days = _weekdays.indexOf(words[1]) + 1 - now.weekday;
      return now.add(Duration(days: days > 0 ? days : days + 7));
    },
  ),
];

final List<TimeToken> _times = [
  TimeToken(
    value: r'\lв|о \lпівдень|півдні',
    getVarValue: (words) => DateTime(1, 1, 1, 12),
  ),
  TimeToken(
    value: r'через \r\b\d+\b \lхвилин|годин',
    getVarValue: (words) {
      DateTime now = DateTime.now();
      switch (words[2][0]) {
        case 'х':
          return now.add(Duration(minutes: int.parse(words[1])));
        default:
          return now.add(Duration(hours: int.parse(words[1])));
      }
    },
  ),
  TimeToken(
    value: r'через \lхвилину|годину',
    getVarValue: (words) {
      DateTime now = DateTime.now();
      switch (words[1][0]) {
        case 'х':
          return now.add(const Duration(minutes: 1));
        default:
          return now.add(const Duration(hours: 1));
      }
    },
  ),
  TimeToken(
    value: r'\o\lо|в \r\b\d+\b:\b\d+\b',
    getVarValue: (words) {
      List<int> numbers =
          words.last.split(':').map((s) => int.parse(s)).toList();
      if (numbers[0] > 23 || numbers[1] > 59) return null;
      return DateTime(1, 1, 1, numbers[0], numbers[1]);
    },
  ),
];

final List<RepeadToken> _repeads = [
  RepeadToken(
    value:
        r'\oна \lкожен|кожного|кожної \lдня|день|неділі|місяця|місяці|року|рік',
    getVarValue: (words) {
      switch (words[words.length - 1][0]) {
        case 'д':
          return Repead.day;
        case 'н':
          return Repead.week;
        case 'м':
          return Repead.month;
        default:
          return Repead.year;
      }
    },
  ),
];

// Token position

class TokenPosition {
  final Token token;
  final int position;
  final List<String> findedWords;
  final double similarity;

  Type get type => token.runtimeType;

  static List<TokenPosition> getWithMaxWordsLen(List<TokenPosition> tokens) {
    if (tokens.isEmpty) return [];
    if (tokens.length == 1) return [tokens[0]];

    int maxWordsLen = Numbs.max(tokens.map((t) => t.findedWords.length).toList());
    return tokens.where((t) => t.findedWords.length == maxWordsLen).toList();
  }

  static Map<TokenPosition, double> getWithMaxPriorityCategories(
    Map<TokenPosition, double> categories,
  ) {
    final Map<Category, double> priorities = {
      Category.task: 0,
      Category.meet: 0,
      Category.birthday: 0,
      Category.holiday: 0,
      Category.notification: 0,
    };

    // find priority category
    for (TokenPosition tp in categories.keys) {
      CategoryToken c = tp.token as CategoryToken;
      priorities[c.category] = priorities[c.category]! + categories[tp]!;
    }
    double maxPriority = Numbs.max(priorities.values.toList());
    Category category =
        priorities.keys.firstWhere((c) => priorities[c] == maxPriority);

    // select all token positions with priority category
    Map<TokenPosition, double> result = {};

    for (TokenPosition tp in categories.keys) {
      CategoryToken c = tp.token as CategoryToken;
      if (c.category == category) result[tp] = categories[tp]!;
    }

    return result;
  }

  T? getVarValue<T>() => (token as VariableToken).getVarValue(findedWords);

  const TokenPosition({
    required this.token,
    required this.position,
    required this.findedWords,
    required this.similarity,
  });
}

// AI

class NLPResult {
  final ItemModel model;
  final QStateModel? state;
  const NLPResult({required this.model, this.state});
}

// Створи нагадування на кожен день ходити в магазин о 12:40
// 28 жовтня 2023 треба сходити в магазин

abstract class NLP {
  static RateWord? _compareWords(String word, String tokenPart) {
    if (tokenPart[0] == '\\') {
      String key = tokenPart[1];
      tokenPart = tokenPart.substring(2);

      if (key == 'r' && word.contains(RegExp(tokenPart))) {
        return RateWord(word, 1);
      } else if (key == 'l') {
        return Token.findSimilar(word, tokenPart.split('|'));
      }
    } else {
      double rate = Token.getSimilariry(word.toLowerCase(), tokenPart);
      if (rate >= Token.thresholdSimilarity) return RateWord(tokenPart, rate);
    }

    return null;
  }

  static List<TokenPosition> _findToken(Token token, List<String> words) {
    List<TokenPosition> tokenPositions = [];
    List<String> parts = token.value.split(' '), findedWords = [];
    List<double> rates = [];
    int partIdx = 0;
    bool isOptional;

    for (int i = 0; i < words.length; i++) {
      String part = parts[partIdx];

      isOptional = part.startsWith(r'\o');
      if (isOptional) part = part.substring(2);

      RateWord? rateWord = _compareWords(words[i], part);

      if (rateWord != null) {
        findedWords.add(rateWord.word);
        rates.add(rateWord.rate);
      } else if (isOptional) {
        i--;
      }

      if (rateWord != null || isOptional) {
        if (++partIdx == parts.length) {
          tokenPositions.add(TokenPosition(
            token: token,
            position: i - findedWords.length + 1,
            findedWords: findedWords,
            similarity: Numbs.avr(rates),
          ));
          partIdx = 0;
          findedWords = [];
          rates.clear();
        }
      } else if (partIdx > 0) {
        i -= findedWords.length;
        partIdx = 0;
        findedWords.clear();
        rates.clear();
      }
    }

    return tokenPositions;
  }

  static List<TokenPosition> _findTokens(List<String> words) {
    if (words.isEmpty) return [];

    // find all tokens
    List<List<Token>> tokenLists = [
      _separators,
      _amplifiers,
      _categories,
      _dates,
      _times,
      _repeads,
    ];
    List<TokenPosition> tp = [];

    for (List<Token> tokens in tokenLists) {
      for (Token token in tokens) {
        tp.addAll(_findToken(token, words));
      }
    }
    if (tp.isEmpty || tp.length == 1) return tp;

    // group tokens for positions
    Map<int, List<TokenPosition>> positions = {};
    for (TokenPosition token in tp) {
      int pos = token.position;
      if (!positions.containsKey(pos)) positions[pos] = [];
      positions[pos]!.add(token);
    }
    tp = [];

    // find tokenn with max finded words and max similarity
    for (int pos in positions.keys) {
      var tokens = TokenPosition.getWithMaxWordsLen(positions[pos]!);
      tp.add(Numbs.getByMax(tokens, (t) => t.similarity));
    }
    tp.sort((item1, item2) => item1.position < item2.position ? -1 : 1);
    return tp;
  }

  static TokenPosition? _getCategoryToken(List<TokenPosition> tokens) {
    Map<TokenPosition, double> categories = {};
    List<TokenPosition> separators = tokens
        .where((t) =>
            t.type == SeparatorToken &&
            (t.token as SeparatorToken).direction != 0)
        .toList();

    // find categories and set priority
    for (int i = 0; i < tokens.length; i++) {
      if (tokens[i].type == CategoryToken) {
        double priority = (tokens[i].token as CategoryToken).priority;

        // find and set before amplifier priority
        if (i > 0 && tokens[i - 1].type == AmplifierToken) {
          priority += (tokens[i - 1].token as AmplifierToken).priority;
        }

        // find and set after amplifier priority
        if (i < tokens.length - 1 && tokens[i + 1].type == AmplifierToken) {
          priority += (tokens[i + 1].token as AmplifierToken).priority;
        }

        // find and set first and last separators priority
        SeparatorToken? firstSepar, lastSepar;

        for (int j = 0; j < separators.length; j++) {
          if (separators[j].position > tokens[i].position) {
            lastSepar = separators[j].token as SeparatorToken;
            break;
          } else {
            firstSepar = separators[j].token as SeparatorToken;
          }
        }

        if (firstSepar != null && firstSepar.direction == 1) {
          priority += firstSepar.priority;
        }
        if (lastSepar != null && lastSepar.direction == -1) {
          priority += lastSepar.priority;
        }

        categories[tokens[i]] = priority;
      }
    }

    if (categories.isEmpty) return null;
    if (categories.length == 1) return categories.keys.first;

    categories = TokenPosition.getWithMaxPriorityCategories(categories);
    if (categories.length == 1) return categories.keys.first;

    return Numbs.getByMax(categories.keys.toList(), (tp) => categories[tp]!);
  }

  static TokenPosition? _getTokenAroundCategory<T extends VariableToken>(
    List<TokenPosition> tokens,
    TokenPosition? category,
  ) {
    List<TokenPosition> items =
        tokens.where((t) => t.type == T && t.getVarValue() != null).toList();

    if (items.isEmpty) return null;
    if (items.length == 1 || category == null) return items[0];

    return Numbs.getByMin(
        items, (t) => (t!.position - category.position).abs());
  }

  static String _getTitle(
    List<String> words,
    TokenPosition? categoryToken,
    TokenPosition? dateToken,
    TokenPosition? timeToken,
    TokenPosition? repeadToken,
    List<TokenPosition> tokens,
  ) {
    // find start and end indexes and select title
    int start = 0, end = words.length;
    CategoryToken? category = categoryToken?.token as CategoryToken?;

    if (category != null &&
        category.category != Category.holiday &&
        category.category != Category.birthday &&
        categoryToken!.position + categoryToken.findedWords.length < words.length) {
      start = categoryToken.position;

      for (TokenPosition token in tokens) {
        if (token.position > start && token.type == SeparatorToken) {
          end = token.position;
          break;
        }
      }
    }
    List<String> titleWords = words.getRange(start, end).toList();

    // remove other tokens
    void removeToken(TokenPosition? t) {
      if (t != null && t.position > start && t.position < end) {
        for (int i = 0; i < t.findedWords.length; i++) {
          titleWords[t.position - start + i] = '';
        }
      }
    }

    removeToken(dateToken);
    removeToken(timeToken);
    removeToken(repeadToken);

    // set category words in titleWords
    if (categoryToken != null) {
      removeToken(categoryToken);
      titleWords[categoryToken.position - start] = categoryToken.token.value;
    }
    titleWords.removeWhere((w) => w.isEmpty);
    return titleWords.join(' ');
  }

  static Future<QStateModel?> _getPriorityState(
    DateTime datetime,
    TokenPosition? categoryToken,
  ) async {
    if (categoryToken == null) return null;

    CategoryToken token = categoryToken.token as CategoryToken;
    if (token.category == Category.birthday ||
        token.category == Category.holiday) {
      return null;
    }

    Duration timeLeft = datetime.difference(DateTime.now());
    return await QStateModel.getState(
      tokenValue: token.value,
      timeDelta: QStateModel.getTimeDelta(timeLeft),
    );
  }

  static Future<NLPResult> getResult(String request) async {
    // Find all tokens
    List<String> words = Token.split(request);
    List<TokenPosition> tokens = _findTokens(words);

    TokenPosition? categoryToken = _getCategoryToken(tokens),
        dateToken = _getTokenAroundCategory<DateToken>(tokens, categoryToken),
        timeToken,
        repeadToken;

    Category category = categoryToken != null
        ? (categoryToken.token as CategoryToken).category
        : Category.notification;

    if (category != Category.birthday || category != Category.holiday) {
      timeToken = _getTokenAroundCategory<TimeToken>(tokens, categoryToken);
      repeadToken = _getTokenAroundCategory<RepeadToken>(tokens, categoryToken);
    }

    // define data from tokens
    String title = _getTitle(
      words,
      categoryToken,
      dateToken,
      timeToken,
      repeadToken,
      tokens,
    );

    DateTime date =
        dateToken != null ? dateToken.getVarValue<DateTime>()! : DateTime.now();
    DateTime time =
        timeToken != null ? timeToken.getVarValue<DateTime>()! : DateTime.now();

    DateTime datetime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);

    Repead repead =
        repeadToken != null ? repeadToken.getVarValue<Repead>()! : Repead.once;

    QStateModel? state = await _getPriorityState(datetime, categoryToken);

    // create model and returning
    ItemModel model = ItemModel(
      title: title,
      datetime: DateTimeData(datetime: datetime, repead: repead),
      category: category,
      priority: state != null ? state.maxQAction : Priority.medium,
    );

    return NLPResult(model: model, state: state);
  }
}
