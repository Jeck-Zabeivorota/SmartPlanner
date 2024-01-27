import '../i_model.dart';
import '../fast_hive.dart';
import 'item_model.dart';

enum TimeDelta { zero, hour, day, week, month, year }

class QStateModel implements IModel {
  static const double _maxQ = 5;
  static const List<Priority> _actions = [
    Priority.low,
    Priority.medium,
    Priority.high
  ];

  @override
  int? id;
  late final String tokenValue;
  late final TimeDelta timeDelta;
  late final List<double> _qValues;

  Priority get maxQAction {
    double maxQ = 0;
    int index = 0;

    for (int i = 0; i < _qValues.length; i++) {
      if (_qValues[i] > maxQ) {
        maxQ = _qValues[i];
        index = i;
      }
    }

    return _actions[index];
  }

  static Future<QStateModel> getState({required String tokenValue, required TimeDelta timeDelta}) async {
    List<QStateModel> states = await FastHive.getAll<QStateModel>();
    QStateModel? state;
    for (QStateModel s in states) {
      if (s.tokenValue == tokenValue && s.timeDelta == timeDelta) {
        state = s;
        break;
      }
    }
    if (state == null) {
      state = QStateModel(tokenValue: tokenValue, timeDelta: timeDelta);
      await FastHive.put(state);
    }
    return state;
  }

  static TimeDelta getTimeDelta(Duration timeLeft) {
    if (timeLeft.inDays >= 30) return TimeDelta.year;
    if (timeLeft.inDays >= 7) return TimeDelta.month;
    if (timeLeft.inDays >= 1) return TimeDelta.week;
    if (timeLeft.inHours >= 1) return TimeDelta.day;
    if (timeLeft.inMinutes >= 1) return TimeDelta.hour;
    return TimeDelta.zero;
  }

  void _addReward(Priority action, double reward) {
    int index = _actions.indexOf(action);
    double q = _qValues[index];

    if ((reward > 0 && q < _maxQ) || (reward < 0 && q > -_maxQ)) {
      _qValues[index] = q + reward;
    }
  }

  void updateQ(Priority correctAction) {
    if (correctAction == Priority.none) throw Exception('incorect action');

    Priority selectedAction = maxQAction;

    _addReward(correctAction, 1);
    if (selectedAction != correctAction) _addReward(selectedAction, -1);
  }

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'tokenValue': tokenValue,
        'timeDelta': timeDelta.toString(),
        'qValues': _qValues,
      };

  @override
  QStateModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    tokenValue = map['tokenValue'];
    timeDelta = TimeDelta.values.firstWhere(
      (td) => td.toString() == map['timeDelta'],
    );
    _qValues = map['qValues'];
  }

  QStateModel({required this.tokenValue, required this.timeDelta})
      : _qValues = [0, 0, 0];
}
