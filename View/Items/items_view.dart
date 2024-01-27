import 'package:flutter/material.dart';
import '../../Instruments/date_duration.dart';
import 'items_viewmodel.dart';
import '../colors.dart';
import '../elements.dart';
import '../Widgets/appbar.dart';
import '../Widgets/add_item.dart';
import 'item.dart';

class ItemsView extends StatefulWidget {
  const ItemsView({super.key});

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  late final ItemsViewModel data;

  Widget _createFilterIndicator() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: ViewColors.accent,
        shape: BoxShape.circle,
        border: Border.all(
          color: ViewColors.background,
          width: 2,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
    );
  }

  Widget _createAppBar() {
    return Appbar(
      first: Templates.iconButton(
        onPressed: () => data.pushBack(context),
        icon: Icons.arrow_back_ios_new_rounded,
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text('Записи', style: TextStyles.text(isBold: true)),
      actions: [
        TextButton(
          onPressed: () => data.sort(isChangeOrder: true),
          style: ButtonStyles.flatButton(
            borderRadius: BorderRadius.circular(25),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 17),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                data.order == Order.toNew
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 18,
                color: ViewColors.text,
              ),
              Icon(Icons.access_time_rounded, size: 15, color: ViewColors.text),
            ],
          ),
        ),
        const SizedBox(width: 3),
        TextButton(
          onPressed: () => data.pushToFilterView(context),
          style: ButtonStyles.flatButton(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          ),
          child: Stack(
            alignment: AlignmentDirectional.topEnd,
            children: [
              Icon(Icons.filter_list, size: 20, color: ViewColors.text),
              data.filterIsDefault
                  ? const SizedBox()
                  : _createFilterIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _createItems() {
    if (data.groups.isEmpty) return [];

    final List<Widget> widgets = [const SizedBox(height: 40)];
    DateTime now = DateTime.now();

    for (DateTime date in data.groups.keys) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 30, top: 30, bottom: 5),
        child: Text(
          DateDuration.dateToString(date, nowDate: now),
          style: TextStyles.text(
            color: ViewColors.text.withAlpha(200),
            isBold: true,
            fontSize: 15,
          ),
        ),
      ));

      widgets.addAll(
        data.groups[date]!.map(
          (model) => Item(
            onPressed: () => data.pushToItemView(context, model: model),
            onDismiss: (_) async => await data.deleteItem(context, model),
            model: model,
          ),
        ),
      );
    }
    widgets.add(const SizedBox(height: 40));

    return widgets;
  }

  @override
  void initState() {
    super.initState();
    data = ItemsViewModel(onUpdate: setState);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = _createItems();

    return Scaffold(
      backgroundColor: ViewColors.background,
      floatingActionButton: AddItem(
        onPressedToAdd: () => data.pushToItemView(context),
        onPressedToRequest: () => data.showRequestDialog(context),
      ),
      body: Stack(children: [
        widgets.isNotEmpty
            ? ListView.builder(
                itemCount: widgets.length,
                itemBuilder: (context, i) => widgets[i],
              )
            : Center(
                child: Text(
                  'Записів не знадено',
                  style: TextStyles.capture(color: ViewColors.text2),
                ),
              ),
        _createAppBar(),
      ]),
    );
  }
}
