import 'package:excel_planner/presentation/%20providers/ui_sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CellEditor extends StatefulWidget {
  final int row;
  final int col;
  final VoidCallback onSaved;
  const CellEditor({super.key, required this.row, required this.col, required this.onSaved});

  @override
  State<CellEditor> createState() => _CellEditorState();
}

class _CellEditorState extends State<CellEditor> {
  late TextEditingController _controller;

  @override
  void initState() {
    final provider = Provider.of<UiSheetProvider>(context, listen: false);
    _controller = TextEditingController(text: provider.cellAt(widget.row, widget.col));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UiSheetProvider>(context, listen: false);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Edit Cell ${_cellRef(widget.row, widget.col)}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: null,
            decoration: InputDecoration(
              hintText: 'Enter value',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            provider.updateCell(widget.row, widget.col, _controller.text);
            widget.onSaved();
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _cellRef(int r, int c) {
    return '${_colName(c)}${r + 1}';
  }

  String _colName(int index) {
    var result = '';
    var i = index;
    while (i >= 0) {
      final rem = i % 26;
      result = String.fromCharCode(65 + rem) + result;
      i = (i ~/ 26) - 1;
    }
    return result;
  }
}
