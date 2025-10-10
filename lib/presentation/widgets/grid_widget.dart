import 'package:dexa_sheet/core/constants.dart';
import 'package:dexa_sheet/presentation/providers/sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cell_editor.dart';

class GridWidget extends StatefulWidget {
  const GridWidget({super.key});

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  int? selectedRow;
  int? selectedCol;

  void _showEditDialog(
    BuildContext context,
    SheetProvider provider,
    int r,
    int c,
  ) {
    // set selection then open editor
    setState(() {
      selectedRow = r;
      selectedCol = c;
    });

    showDialog(
      context: context,
      builder:
          (_) => CellEditor(
            row: r,
            col: c,
            onSaved: () {
              // keep selection after save (optional)
              setState(() {});
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SheetProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final sheet = provider.sheet;

        final data = sheet.data;
        final rows = data.length;
        final cols = data.isNotEmpty ? data[0].length : 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            // compute required content width for all columns
            final requiredWidth =
                cols * Constants.cellWidth + Constants.leftHeaderWidth;
            // ensure scroll container is at least as wide as the screen to avoid underflow
            final minWidth =
                requiredWidth > constraints.maxWidth
                    ? requiredWidth
                    : constraints.maxWidth;

            return Column(
              children: [
                // Top search placeholder & header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
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
                          child: const Text(
                            'Search or type to filter...',
                            style: TextStyle(color: Colors.black54),
                          ),
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
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.filter_list,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Column headers (scrollable horizontally)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minWidth),
                    child: Row(
                      children: [
                        SizedBox(
                          width: Constants.leftHeaderWidth,
                          height: Constants.headerHeight,
                        ),
                        for (var c = 0; c < cols; c++) _headerCell(context, c),
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Grid body
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: minWidth),
                        child: SingleChildScrollView(
                          // vertical scrolling container
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(rows, (rIdx) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Row header
                                  Container(
                                    width: Constants.leftHeaderWidth,
                                    height: Constants.cellHeight,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      border: Border(
                                        right: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                        bottom: BorderSide(
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Row number
                                          Text(
                                            '${rIdx + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Row actions
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            iconSize: 18,
                                            onSelected: (v) {
                                              final prov =
                                                  Provider.of<SheetProvider>(
                                                    context,
                                                    listen: false,
                                                  );
                                              if (v == 'add')
                                                prov.addRow(index: rIdx);
                                              if (v == 'del')
                                                prov.removeRow(rIdx);
                                            },
                                            itemBuilder:
                                                (_) => const [
                                                  PopupMenuItem(
                                                    value: 'add',
                                                    child: Text(
                                                      'Add row below',
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'del',
                                                    child: Text('Delete row'),
                                                  ),
                                                ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Cells
                                  for (var c = 0; c < cols; c++)
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        _showEditDialog(
                                          context,
                                          provider,
                                          rIdx,
                                          c,
                                        );
                                      },
                                      child: Container(
                                        width: Constants.cellWidth,
                                        height: Constants.cellHeight,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          color:
                                              (selectedRow == rIdx &&
                                                      selectedCol == c)
                                                  ? Colors.lightGreen.shade100
                                                  : Colors.white,
                                        ),
                                        child: Text(
                                          provider.cellAt(rIdx, c),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _headerCell(BuildContext context, int c) {
    final provider = Provider.of<SheetProvider>(context, listen: false);
    return Container(
      width: Constants.cellWidth,
      height: Constants.headerHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
      ),
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        onSelected: (v) {
          if (v == 'add') {
            provider.addColumn(index: c);
          } else if (v == 'del') {
            provider.removeColumn(c);
          }
        },
        itemBuilder:
            (_) => const [
              PopupMenuItem(value: 'add', child: Text('Add column right')),
              PopupMenuItem(value: 'del', child: Text('Delete column')),
            ],
        child: Center(
          child: Text(
            _colName(c),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
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
