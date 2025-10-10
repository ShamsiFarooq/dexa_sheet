import 'dart:io';

import 'package:dexa_sheet/presentation/providers/sheet_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/grid_widget.dart';

class HomePage extends StatefulWidget {
  final String sheetId;
  const HomePage({super.key, required this.sheetId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SheetProvider>(context, listen: false).load(widget.sheetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Provider inline rather than storing a late field.
    // final provider = Provider.of<SheetProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Dexa Sheet'),
        actions: [
          IconButton(
            tooltip: 'Sheet saved',
            icon: const Icon(Icons.save),
            onPressed: () async {
               final uid = FirebaseAuth.instance.currentUser?.uid;
  debugPrint('Dexa DEBUG Save tap. uid=$uid');
  try {
    await Provider.of<SheetProvider>(context, listen: false).save();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sheet saved')));
  } catch (e, st) {
    debugPrint('Save FAILED: $e\n$st');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save error: $e')));
  }
            },
          ),
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.file_download),
            onPressed: () async {
              final prov = Provider.of<SheetProvider>(context, listen: false);
              final csv = prov.exportCsv();
              await _saveCsvToTemp(csv);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SafeArea(child: GridWidget()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2E7D32),
        child: const Icon(Icons.add),
        onPressed:
            () => Provider.of<SheetProvider>(context, listen: false).addRow(),
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

  Future<void> _saveCsvToTemp(String csv) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sheet_export.csv');
      await file.writeAsString(csv);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('CSV exported: ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exporting CSV: $e')));
    }
  }
}
