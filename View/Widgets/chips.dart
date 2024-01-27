import 'package:flutter/material.dart';
import '../colors.dart';
import '../elements.dart';

class ChipsController<TKey> {
  final Map<TKey, String> chipsData;
  final List<TKey> activeKeys;
  Color? colorActive;

  ChipsController({
    required this.chipsData,
    List<TKey>? activeKeys,
    this.colorActive,
  }) : activeKeys = activeKeys ?? [] {
    for (TKey key in this.activeKeys) {
      if (!chipsData.containsKey(key)) {
        throw Exception('Active key not found in "chipsData"');
      }
    }
  }

  void toggleChip(TKey key) {
    if (!chipsData.containsKey(key)) throw Exception('key not found');

    if (activeKeys.contains(key)) {
      activeKeys.remove(key);
    } else {
      activeKeys.add(key);
    }
  }

  void setChip(TKey key) {
    if (!chipsData.containsKey(key)) throw Exception('key not found');
    activeKeys.clear();
    activeKeys.add(key);
  }

  bool isNoOneActive() => activeKeys.isEmpty;
}

class Chips<TKey> extends StatefulWidget {
  final ChipsController<TKey> controller;
  final void Function(TKey)? onPressed;
  final bool multiple;

  const Chips({
    super.key,
    this.onPressed,
    required this.controller,
    this.multiple = false,
  });

  @override
  State<Chips<TKey>> createState() => _ChipsState<TKey>();
}

class _ChipsState<TKey> extends State<Chips<TKey>> {
  @override
  Widget build(BuildContext context) {
    var control = widget.controller;
    final List<Widget> chips = [];

    for (TKey id in control.chipsData.keys) {
      bool isActive = control.activeKeys.contains(id);

      chips.add(ElevatedButton(
        onPressed: () => setState(() {
          if (widget.multiple) {
            control.toggleChip(id);
          } else {
            control.setChip(id);
          }
          if (widget.onPressed != null) widget.onPressed!(id);
        }),
        style: ButtonStyles.elevatedButton(
          borderRadius: BorderRadius.circular(20),
          backgroundColor: isActive ? control.colorActive : ViewColors.second,
          elevation: isActive ? 5 : 0,
          shadowColor:
              (control.colorActive ?? ViewColors.accent).withOpacity(0.25),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
        child: Text(
          control.chipsData[id]!,
          style: TextStyles.text(color: isActive ? Colors.white : null),
        ),
      ));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: chips,
    );
  }
}
