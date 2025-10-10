
import 'package:dexa_sheet/core/constants.dart';
import 'package:dexa_sheet/data/datasources/local_datasource.dart';
import 'package:dexa_sheet/data/repositories/sheet_repository_impl.dart';
import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/presentation/pages/home_page.dart';
import 'package:dexa_sheet/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class SheetListPage extends StatefulWidget {
  const SheetListPage({super.key});
  @override
  State<SheetListPage> createState() => _SheetListPageState();
}

class _SheetListPageState extends State<SheetListPage> {
  late Box box;
  late LocalDataSource ds;
  late SheetRepositoryImpl repo;
  List<SheetMeta> meta = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

 Future<void> _init() async {
  box = Hive.box(Constants.hiveBoxName);
  ds = LocalDataSource(box);
  repo = SheetRepositoryImpl(ds);
  await _refreshList();
}

Future<void> _refreshList() async {
  final list = await repo.getAllSheets();

  // ✅ Sort by last modified (newest first)
  list.sort((a, b) => b.lastModified.compareTo(a.lastModified));

  setState(() {
    meta = list;
  });
}


  Future<void> _createNew() async {
    final sheet = Sheet.empty(name: 'Untitled ${meta.length + 1}');
    await repo.saveSheet(sheet);
    meta = await repo.getAllSheets();
    setState(() {});
    await _refreshList();

    _openSheet(sheet.id);
  }

  Future<void> _openSheet(String id) async {
    Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => HomePage(sheetId: id)),
).then((_) => _refreshList());

  }

  Future<void> _rename(SheetMeta m) async {
    final controller = TextEditingController(text: m.name);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename sheet'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await repo.renameSheet(m.id, controller.text);
              Navigator.pop(context);
              _init();
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
      builder: (_) => AlertDialog(
        title: const Text('Delete sheet?'),
        content: Text('Are you sure you want to delete "${m.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm ?? false) {
      await repo.deleteSheet(m.id);
      _init();
    }
    await _refreshList();

  }

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
      Text('Dexa sheet', style: TextStyle(fontWeight: FontWeight.w600)),
    ],
  ),
  actions: [
     if (auth.user != null)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sign out',
              onPressed: () async {
                await context.read<AuthProvider>().signOut();
                // After sign out, AuthGate will auto-redirect to SignInPage
              },
            ),
    IconButton(
      icon: const Icon(Icons.add, color: Colors.white),
      onPressed: _createNew,
      tooltip: 'Create new sheet',
    ),
  ],
),

      body: meta.isEmpty
    ? const Center(child: Text('No sheets yet. Tap + to create one.'))
    : RefreshIndicator(
        onRefresh: _refreshList,
        child: ListView.builder(
          itemCount: meta.length,
          itemBuilder: (_, i) {
            final m = meta[i];
            return ListTile(
              title: Text(m.name),
              subtitle: Text(
                'Last modified: ${DateFormatter.format(m.lastModified)}', // ✅ prettier date
              ),
              onTap: () => _openSheet(m.id),
              trailing: PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'rename') _rename(m);
                  if (v == 'delete') _delete(m);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'rename', child: Text('Rename')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            );
          },  

        ),
      ),

    );
  }
}
