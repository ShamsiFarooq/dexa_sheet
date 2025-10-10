


import 'package:dexa_sheet/domain/entities/sheet.dart';
import 'package:dexa_sheet/domain/repositories/sheet_repository.dart';


class LoadSheetUseCase {
  final SheetRepository repository;

  LoadSheetUseCase({required this.repository});

  Future<Sheet> call(String id) async {
    return await repository.loadSheet(id);
  }
}