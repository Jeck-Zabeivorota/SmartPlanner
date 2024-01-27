import 'package:flutter/material.dart';
import 'home_viewmodel.dart';
import '../colors.dart';
import '../elements.dart';
import 'calendar.dart';
import '../Widgets/chips.dart';
import '../Widgets/add_item.dart';
import '../Items/item.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel data;

  Widget _createActionButton({
    required void Function() onPressed,
    required IconData icon,
  }) {
    return Templates.iconButton(
      onPressed: onPressed,
      borderRadius: BorderRadius.circular(40),
      iconSize: 20,
      icon: icon,
    );
  }

  Widget _createItemsPanel() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10, left: 30, right: 30),
      child: Templates.rowPanel(
        first: Text(data.selectedDateTitle, style: TextStyles.capture()),
        actions: [
          Chips(
            onPressed: (_) => setState(() {}),
            controller: data.holidaysControl,
            multiple: true,
          )
        ],
      ),
    );
  }

  Widget _createCalendar() {
    return Calendar(
      onSelectDay: () => data.updateSelectedDayItems(),
      controller: data.calendarControl,
      panelActions: [
        _createActionButton(
          onPressed: data.changeTheme,
          icon: data.colorThemeIcon,
        ),
        const SizedBox(width: 15),
        _createActionButton(
          onPressed: () => data.pushToItemsView(context),
          icon: Icons.format_list_bulleted_rounded,
        ),
      ],
    );
  }

  Widget _createItems({required bool scrollable}) {
    final List<Widget> items = [_createItemsPanel()];

    if (data.selectedDateItems.isNotEmpty) {
      items.addAll(data.selectedDateItems.map(
        (model) => Item(
          onPressed: () => data.pushToItemView(context, model: model),
          onDismiss: (_) async => await data.deleteItem(context, model),
          model: model,
        ),
      ));
      items.add(SizedBox(height: data.selectedDateItems.length > 3 ? 40 : 100));
    } else {
      items.add(Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 200),
        child: Center(
          child: Text(
            data.holidaysControl.isNoOneActive()
                ? 'Записів не знайдено'
                : 'Свят не знайдено',
            style: TextStyles.capture(color: ViewColors.text2),
          ),
        ),
      ));
    }

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: ViewColors.background,
        borderRadius: scrollable
            ? const BorderRadius.horizontal(right: Radius.circular(20))
            : const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: ViewColors.second),
        boxShadow: [
          BoxShadow(
            color: ViewColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, -20),
          )
        ],
      ),
      child: scrollable
          ? ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => items[i],
            )
          : Column(children: items),
    );
  }

  Widget _createVerticalContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: _createCalendar(),
          ),
          _createItems(scrollable: false),
        ],
      ),
    );
  }

  Widget _createHorizontalContent(double height) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _createItems(scrollable: true)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: _createCalendar(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    data = HomeViewModel(onUpdate: setState);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ViewColors.background2,
      floatingActionButton: AddItem(
        onPressedToAdd: () => data.pushToItemView(context),
        onPressedToRequest: () => data.showRequestDialog(context),
      ),
      body: size.width > 700
          ? _createHorizontalContent(size.height)
          : _createVerticalContent(),
    );
  }
}
