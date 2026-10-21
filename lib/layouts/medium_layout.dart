import 'package:flutter/material.dart';
import '../main.dart' show studentId, studentName;

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.green.shade100, 
      child: Text(
        '$studentId\n$studentName\nKategori: Medium Layout', 
        textAlign: TextAlign.center, 
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}