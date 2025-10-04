import 'package:excel_planner/core/constants.dart';
import 'package:excel_planner/presentation/%20providers/ui_sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cell_editor.dart';

class GridWidget extends StatelessWidget {
  const GridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UiSheetProvider>(builder: (context, provider, child) {
      if (provider.isLoading) return const Center(child: CircularProgressIndicator());

      final data = provider.data;
      final rows = data.length;
      final cols = data.isNotEmpty ? data[0].length : 0;

      // Column headers row (A, B, C...)
      final headerRow = Row(
        children: [
          SizedBox(width: Constants.leftHeaderWidth, height: Constants.headerHeight),
          for (var c = 0; c < cols; c++) headerCell(c),
        ],
      );

      return Column(
        children: [
          // Top search placeholder & header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text('Search or type to filter...', style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0,2))],
                  ),
                  child: Icon(Icons.filter_list, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          // Column headers (scrollable horizontally)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: headerRow,
          ),

          const Divider(height: 1),

          // Grid body
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: cols * Constants.cellWidth + Constants.leftHeaderWidth,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: rows,
                    itemBuilder: (context, rIdx) {
                      return Row(
                        children: [
                          // Row header
                          Container(
                            width: Constants.leftHeaderWidth,
                            height: Constants.cellHeight,
                            decoration: BoxDecoration(color: Colors.grey.shade100, border: Border(right: BorderSide(color: Colors.grey.shade300), bottom: BorderSide(color: Colors.grey.shade300))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${rIdx + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 6),
                                PopupMenuButton<String>(
                                  iconSize: 16,
                                  onSelected: (v) {
                                    if (v == 'add') Provider.of<UiSheetProvider>(context, listen:false).addRow(at: rIdx+1);
                                    if (v == 'del') Provider.of<UiSheetProvider>(context, listen:false).removeRow(rIdx);
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(value: 'add', child: Text('Add row below')),
                                    PopupMenuItem(value: 'del', child: Text('Delete row')),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // Cells
                          for (var c = 0; c < cols; c++)
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CellEditor(row: rIdx, col: c, onSaved: () {}),
                                );
                              },
                              child: Container(
                                width: Constants.cellWidth,
                                height: Constants.cellHeight,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300),
                                    bottom: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Text(provider.cellAt(rIdx, c)),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget headerCell(int c) {
    return Container(
      width: Constants.cellWidth,
      height: Constants.headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9), // subtle green tint
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Text(_colName(c), style: const TextStyle(fontWeight: FontWeight.w700)),
    );
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
