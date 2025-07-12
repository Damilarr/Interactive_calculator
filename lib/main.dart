import 'package:flutter/material.dart';
import 'package:interactive_calculator/calculator_ui.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interactive Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorApp(),
    );
  }
}
