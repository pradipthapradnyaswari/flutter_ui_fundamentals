
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/profile_service.dart';
import '../main.dart' show studentId, studentName;

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);

  final _formKey = GlobalKey<FormState>();
  late Future<UserProfile?> _profileFuture;

  bool _isSaving = false;

  String _code = '';
  String _title = '';
  int _credits = 0;
  String _status = 'planned';

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final newCourse = Course(
      code: _code,
      title: _title,
      credits: _credits,
      status: _status,
    );

    final provider = context.read<CourseProvider>();
    final success = await provider.addCourse(newCourse);

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Ditolak'),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Anda tidak memiliki izin untuk menambahkan course.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Course Baru'),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$studentName - $studentId',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Kode Course',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Kode wajib diisi'
                      : null,
              onSaved: (value) => _code = value!,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Judul Course',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Judul wajib diisi'
                      : null,
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),

            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Jumlah SKS',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'SKS wajib diisi';
                }
                if (int.tryParse(value) == null) {
                  return 'SKS harus berupa angka';
                }
                return null;
              },
              onSaved: (value) => _credits = int.parse(value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'planned',
                  child: Text('Planned'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'done',
                  child: Text('Done'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan Course',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Memeriksa Akses'),
              backgroundColor: _darkBlue,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final profile = snapshot.data;

        if (snapshot.hasError ||
            profile == null ||
            !['lecturer', 'admin'].contains(profile.role)) {
          return _buildAccessDenied();
        }

        return _buildForm();
      },
    );
  }
}
