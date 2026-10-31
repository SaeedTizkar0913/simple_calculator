import 'package:flutter/material.dart';
import 'package:simple_calculator/pages/calculator_page.dart';

void main() {
  runApp(const CalculatorApp());
}

// The root widget. It just creates a MaterialApp and shows our calculator page.
class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Simple Calculator')),
        body: const CalculatorPage(),
      ),
    );
  }
}
