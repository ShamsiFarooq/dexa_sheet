

import 'package:excel_planner/domain/entities/sheet.dart';
import 'package:excel_planner/domain/repositories/sheet_repository.dart';

class LoadSheetUseCase {
  final SheetRepository repository;
  LoadSheetUseCase(this.repository);

  Future<Sheet> call(String id) async {
    return repository.loadSheet(id);
  }
}