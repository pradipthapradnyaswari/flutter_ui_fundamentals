import 'package:flutter/material.dart';
// Sesuaikan variabel nama/NIM yang Anda deklarasikan di main.dart
import '../main.dart' show studentName, studentId;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/profil.jpg'),
          ),
          const SizedBox(height: 16),
          Text(
            studentName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'NIM: $studentId',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const Divider(height: 32),
          const ListTile(
            leading: Icon(Icons.email),
            title: Text('Email Mahasiswa'),
            subtitle: Text('pradiptha@student.undiksha.ac.id'),
          ),
          const ListTile(
            leading: Icon(Icons.school),
            title: Text('Program Studi'),
            subtitle: Text('Pendidikan Teknik Informatika'),
          ),
        ],
      ),
    );
  }
}