import 'package:flutter/material.dart';
import '../elements.dart';

class AddItem extends StatefulWidget {
  final void Function() onPressedToAdd, onPressedToRequest;

  const AddItem({
    super.key,
    required this.onPressedToAdd,
    required this.onPressedToRequest,
  });

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  bool _isShowActions = false;
  final TextEditingController _requestFieldControl = TextEditingController();

  Widget _createToggle() {
    return ElevatedButton(
      onPressed: () => setState(() => _isShowActions = !_isShowActions),
      style: ButtonStyles.elevatedButton(
        backgroundColor: _isShowActions ? Colors.red : null,
        shadowColor: _isShowActions ? Colors.red : null,
        borderRadius: BorderRadius.circular(40),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
      ),
      child: Icon(
        _isShowActions ? Icons.close_rounded : Icons.add_rounded,
        size: 40,
        color: Colors.white,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _requestFieldControl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isShowActions) return _createToggle();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            widget.onPressedToRequest();
            setState(() => _isShowActions = false);
          },
          style: ButtonStyles.elevatedButton(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.send_rounded, size: 20, color: Colors.white),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: () {
            widget.onPressedToAdd();
            setState(() => _isShowActions = false);
          },
          style: ButtonStyles.elevatedButton(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 13),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 15),
        _createToggle(),
      ],
    );
  }
}
