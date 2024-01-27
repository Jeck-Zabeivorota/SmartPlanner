import 'package:flutter/material.dart';
import '../../Database/Models/item_model.dart';
import '../colors.dart';
import '../elements.dart';
import 'item_viewmodel.dart';
import '../Widgets/appbar.dart';
import '../Widgets/chips.dart';
import '../Widgets/date_field.dart';
import '../Widgets/time_field.dart';

class ItemView extends StatefulWidget {
  final ItemModel? model;
  final String? request;

  const ItemView({super.key, this.model, this.request});

  @override
  State<ItemView> createState() => _ItemViewState();
}

class _ItemViewState extends State<ItemView> {
  late final ItemViewModel data;

  Widget _createAppBar() {
    return Appbar(
      first: Templates.iconButton(
        onPressed: () => Navigator.pop(context),
        icon: Icons.arrow_back_ios_new_rounded,
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('Створити запис', style: TextStyles.text(isBold: true)),
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
            data.id == null ? 'Створити' : 'Зберегти',
            style: TextStyles.text(color: ViewColors.background, isBold: true),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    data = ItemViewModel(
      onUpdate: setState,
      model: widget.model,
      request: widget.request,
    );
  }

  @override
  void dispose() {
    super.dispose();
    data.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 40;

    final List<Widget> widgets;

    if (data.isShowFields) {
      widgets = [
        Templates.field(
          label: 'Назва',
          child: TextField(
            controller: data.titleControl,
            decoration: InputDecorations.field(),
            style: TextStyles.text(),
          ),
        ),
        const SizedBox(height: padding),
        Templates.field(
          label: 'Категорія',
          child: Chips(
            onPressed: data.changeCategory,
            controller: data.categoryControl,
          ),
        ),
        const SizedBox(height: padding),
        Wrap(
          spacing: 30,
          runSpacing: 30,
          children: [
            DateField(controller: data.dateControl),
            TimeField(controller: data.timeControl),
          ],
        ),
      ];

      if (!data.isHolidayOrBirthday) {
        widgets.addAll([
          const SizedBox(height: padding),
          Templates.field(
            label: 'Приорітет',
            child: Chips(
              onPressed: data.setPriorityChipColor,
              controller: data.priorityControl,
            ),
          ),
          const SizedBox(height: padding),
          Templates.field(
            label: 'Повторення',
            child: Chips(controller: data.repeadControl),
          ),
        ]);
      }
    } else {
      widgets = [];
    }

    return Scaffold(
      backgroundColor: ViewColors.background,
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: widgets,
            ),
          ),
        ),
        _createAppBar(),
      ]),
    );
  }
}
