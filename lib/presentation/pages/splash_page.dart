import 'dart:async';
import 'package:flutter/material.dart';
import 'sheet_list_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();

    // Fade in the logo, then navigate after 2 seconds
    Timer(const Duration(milliseconds: 300), () {
      setState(() => _opacity = 1);
    });

    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SheetListPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32), // Excel green
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_chart_rounded, size: 90, color: Colors.white),
              SizedBox(height: 20),

              SizedBox(height: 10),
              Text(
                'Your personal sheet workspace',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
