
import 'package:dexa_sheet/data/datasources/firebase_sheet_datasource.dart';
import 'package:dexa_sheet/data/repositories/firebase_auth_repository.dart';
import 'package:dexa_sheet/data/repositories/firebase_sheet_repository.dart';
import 'package:dexa_sheet/firebase_options.dart';
import 'package:dexa_sheet/presentation/providers/auth_provider.dart';
import 'package:dexa_sheet/presentation/providers/sheet_provider.dart';
import 'package:dexa_sheet/presentation/pages/splash_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'domain/usecases/load_sheet_usecase.dart';
import 'domain/usecases/save_sheet_usecase.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  

await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  final firebaseDataSource = FirebaseSheetDataSource();
  final firebaseRepo = FirebaseSheetRepository(ds: firebaseDataSource);

  final loadUseCase = LoadSheetUseCase(repository: firebaseRepo);
  final saveUseCase = SaveSheetUseCase(repository: firebaseRepo);

  runApp(MyApp(loadUseCase: loadUseCase, saveUseCase: saveUseCase));
}

class MyApp extends StatelessWidget {
    final firebaseRepo = FirebaseSheetRepository(ds: FirebaseSheetDataSource());

  final LoadSheetUseCase loadUseCase;
  final SaveSheetUseCase saveUseCase;
   MyApp({
    super.key,
    required this.loadUseCase,
    required this.saveUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(FirebaseAuthRepository())),
       ChangeNotifierProvider(
        create: (_) => SheetProvider(loadUseCase: loadUseCase, saveUseCase: saveUseCase),
      ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Dexa Sheet',
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

          home: const SplashRouter(),
      ),
    );
  }
}
