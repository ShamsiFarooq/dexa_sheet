import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/presentation/pages/home_page.dart';
import 'package:dexa_sheet/presentation/providers/auth_provider.dart';
import 'package:dexa_sheet/presentation/providers/sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SheetListPage extends StatefulWidget {
  const SheetListPage({super.key});
  @override
  State<SheetListPage> createState() => _SheetListPageState();
}

class _SheetListPageState extends State<SheetListPage> {
  List<SheetMeta> meta = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  Future<void> _refreshList() async {
    setState(() => _loading = true);
    try {
      final provider = context.read<SheetProvider>();
      final list = await provider.getAllSheets();
      // newest first
      list.sort((a, b) => b.lastModified.compareTo(a.lastModified));
      setState(() {
        meta = list;
      });
    } catch (e) {
      debugPrint('List fetch error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createNew() async {
    final provider = context.read<SheetProvider>();
    await provider.createNewSheet(name: 'Untitled ${meta.length + 1}');
    // After creating, provider.sheet is the newly created one
    final newId = provider.sheet.id;
    await _refreshList();
    _openSheet(newId);
  }

  Future<void> _openSheet(String id) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomePage(sheetId: id)),
    );
    if (!mounted) return;
    await _refreshList();
  }

  Future<void> _rename(SheetMeta m) async {
    final controller = TextEditingController(text: m.name);
    final provider = context.read<SheetProvider>();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Rename sheet'),
            content: TextField(controller: controller),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // load, then rename via provider’s API
                  await provider.load(m.id);
                  await provider.renameActiveSheet(controller.text);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
    await _refreshList();
  }

  Future<void> _delete(SheetMeta m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete sheet?'),
            content: Text('Are you sure you want to delete "${m.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
    if (confirm ?? false) {
      final provider = context.read<SheetProvider>();
      await provider.deleteSheet(m.id);
      await Future.delayed(const Duration(milliseconds: 500)); // add this line
      await _refreshList(); // now Firestore deletion reflects correctly
    }
  }

  String _fmt(DateTime d) => DateFormat('yMMMd • HH:mm').format(d);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E7D32),
        title: Row(
          children: const [
            Icon(Icons.table_chart_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Dexa Sheet', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: _refreshList,
          ),
          if (auth.user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
              },
            ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _createNew,
            tooltip: 'Create new sheet',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : meta.isEmpty
              ? const Center(child: Text('No sheets yet. Tap + to create one.'))
              : RefreshIndicator(
                onRefresh: _refreshList,
                child: ListView.builder(
                  itemCount: meta.length,
                  itemBuilder: (_, i) {
                    final m = meta[i];
                    return ListTile(
                      title: Text(m.name),
                      subtitle: Text('Last modified: ${_fmt(m.lastModified)}'),
                      onTap: () => _openSheet(m.id),
                      trailing: PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == 'rename') _rename(m);
                          if (v == 'delete') _delete(m);
                        },
                        itemBuilder:
                            (_) => const [
                              PopupMenuItem(
                                value: 'rename',
                                child: Text('Rename'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
