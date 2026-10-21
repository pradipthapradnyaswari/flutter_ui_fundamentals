import 'package:flutter/material.dart';
import '../main.dart' show studentId, studentName;

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.purple.shade100, 
      child: Text(
        '$studentId\n$studentName\nKategori: Expanded Layout', 
        textAlign: TextAlign.center, 
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}