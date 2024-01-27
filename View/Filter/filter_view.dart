import 'package:flutter/material.dart';
import 'filter_viewmodel.dart';
import 'filter.dart';
import '../colors.dart';
import '../elements.dart';
import '../Widgets/appbar.dart';
import '../Widgets/chips.dart';
import '../Widgets/checkbox.dart';
import '../Widgets/date_field.dart';
import '../Widgets/time_field.dart';

class FilterView extends StatefulWidget {
  final Filter filter;

  const FilterView({super.key, required this.filter});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  late final FilterViewModel data;

  Widget _createAppBar() {
    return Appbar(
      first: Templates.iconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icons.arrow_back_ios_new_rounded,
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('Фільтер', style: TextStyles.text(isBold: true)),
      actions: [
        ElevatedButton(
          onPressed: () => data.save(context),
          style: ButtonStyles.elevatedButton(
            backgroundColor: ViewColors.text,
            shadowColor: ViewColors.shadow,
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(10),
          ),
          child: Text(
            'Задати',
            style: TextStyles.text(color: ViewColors.background, isBold: true),
          ),
        ),
      ],
    );
  }

  Widget _createfieldForDateTime({
    required String label,
    required CheckBoxController checkboxController,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: ViewColors.second, width: 2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyles.text(color: ViewColors.text.withAlpha(140)),
              ),
              const SizedBox(width: 10),
              CheckBox(controller: checkboxController),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _createDateTimeFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _createfieldForDateTime(
          label: 'Початок',
          checkboxController: data.isStartDateTimeControl,
          child: Wrap(spacing: 30, runSpacing: 30, children: [
            DateField(controller: data.startDateControl),
            TimeField(controller: data.startTimeControl),
          ]),
        ),
        const SizedBox(height: 30),
        _createfieldForDateTime(
          label: 'Кінець',
          checkboxController: data.isEndDateTimeControl,
          child: Wrap(spacing: 30, runSpacing: 30, children: [
            DateField(controller: data.endDateControl),
            TimeField(controller: data.endTimeControl),
          ]),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    data = FilterViewModel(onUpdate: setState, filter: widget.filter);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 40, indent = 10;

    return Scaffold(
      backgroundColor: ViewColors.background,
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Templates.field(
                  label: 'Категорії',
                  style: TextStyles.capture(),
                  indent: indent,
                  child: Chips(
                    controller: data.categoriesControl,
                    multiple: true,
                  ),
                ),
                const SizedBox(height: padding),
                Templates.field(
                  label: 'Пріоритети',
                  style: TextStyles.capture(),
                  indent: indent,
                  child: Chips(
                    controller: data.prioritetsControl,
                    multiple: true,
                  ),
                ),
                const SizedBox(height: padding),
                Templates.field(
                  label: 'Період',
                  style: TextStyles.capture(),
                  indent: indent,
                  child: _createDateTimeFields(),
                ),
                const SizedBox(height: padding),
                Templates.field(
                  label: 'Назва',
                  style: TextStyles.capture(),
                  indent: indent,
                  child: TextField(
                    controller: data.titleControl,
                    decoration: InputDecorations.field(),
                    style: TextStyles.text(),
                  ),
                ),
                const SizedBox(height: padding),
                Templates.field(
                  label: 'Повторення',
                  style: TextStyles.capture(),
                  indent: indent,
                  child: Chips(
                    controller: data.repeadControl,
                    multiple: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        _createAppBar(),
      ]),
    );
  }
}
