import 'package:excel_planner/presentation/%20providers/ui_sheet_provider.dart';
import 'package:excel_planner/presentation/widgets/grid_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UiSheetProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Excel-like Planner'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SafeArea(child: GridWidget()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
        onPressed: () => provider.addRow(),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.home_outlined),
              SizedBox(width: 8),
              Text('Home'),
            ],
          ),
        ),
      ),
    );
  }
}
