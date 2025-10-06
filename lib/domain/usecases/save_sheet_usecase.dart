

import 'package:excel_planner/domain/entities/sheet.dart';
import 'package:excel_planner/domain/repositories/sheet_repository.dart';

class SaveSheetUseCase {
  final SheetRepository repository;
  SaveSheetUseCase(this.repository);

  Future<void> call(Sheet sheet) async {
    return repository.saveSheet(sheet);
  }
}
