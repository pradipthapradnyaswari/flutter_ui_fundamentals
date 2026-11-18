
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
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
  bool _isSaving = false;

  String _code = '';
  String _title = '';
  int _credits = 0;
  String _status = 'planned';

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

  @override
  Widget build(BuildContext context) {
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
}
