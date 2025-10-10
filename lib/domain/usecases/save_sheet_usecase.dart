


import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/domain/repositories/sheet_repository.dart';

class SaveSheetUseCase {
  final SheetRepository repository;

  SaveSheetUseCase({required this.repository});

  Future<void> call(Sheet sheet) async {
    await repository.saveSheet(sheet);
  }
}