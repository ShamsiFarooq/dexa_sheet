import 'package:excel_planner/presentation/%20providers/ui_sheet_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UiSheetProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Excel-like Planner (UI)',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
