
import 'package:dexa_sheet/presentation/%20providers/sheet_provider.dart';
import 'package:dexa_sheet/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants.dart';
import 'data/datasources/local_datasource.dart';
import 'data/repositories/sheet_repository_impl.dart';
import 'domain/usecases/load_sheet_usecase.dart';
import 'domain/usecases/save_sheet_usecase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox(Constants.hiveBoxName);

  final localDataSource = LocalDataSource(box);
  final repository = SheetRepositoryImpl(localDataSource);
  final loadUseCase = LoadSheetUseCase(repository);
  final saveUseCase = SaveSheetUseCase(repository);

  runApp(MyApp(loadUseCase: loadUseCase, saveUseCase: saveUseCase));
}

class MyApp extends StatelessWidget {
  final LoadSheetUseCase loadUseCase;
  final SaveSheetUseCase saveUseCase;
  const MyApp({
    super.key,
    required this.loadUseCase,
    required this.saveUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create:
              (_) => SheetProvider(
                loadUseCase: loadUseCase,
                saveUseCase: saveUseCase,
              ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Excel-like Planner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 14)),
        ),

        home: const SplashPage(),
      ),
    );
  }
}
