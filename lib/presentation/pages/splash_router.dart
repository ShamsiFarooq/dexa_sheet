import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_gate.dart';

class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  @override
  void initState() {
    super.initState();
    // Small delay so your Flutter splash is visible after native splash
    Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Your existing splash UI (green screen + logo + tagline)
    return Scaffold(
      body: Container(
        color: const Color(0xFF2E7D32),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.grid_on_rounded, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('Your personal sheet workspace',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
