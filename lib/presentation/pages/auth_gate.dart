import 'package:dexa_sheet/presentation/pages/sheet_list_page.dart';
import 'package:dexa_sheet/presentation/pages/sign_in_page.dart.dart';
import 'package:dexa_sheet/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.user == null) {
      return const SignInPage();
    }
    return const SheetListPage(); // logged-in experience
  }
}
