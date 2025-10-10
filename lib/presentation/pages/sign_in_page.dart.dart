import 'package:dexa_sheet/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Sign in to Dexa Sheet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            if (auth.error != null) Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(auth.error!, style: const TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: Text(auth.isLoading ? 'Signing in...' : 'Continue with Google'),
              onPressed: auth.isLoading ? null : () => context.read<AuthProvider>().signInWithGoogle(),
              style: ElevatedButton.styleFrom(minimumSize: const Size(260, 44)),
            ),
          ],
        ),
      ),
    );
  }
}
