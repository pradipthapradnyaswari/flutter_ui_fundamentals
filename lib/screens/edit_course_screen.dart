import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../main.dart' show studentId, studentName;

class EditCourseScreen extends StatefulWidget {
  final Course course;

  const EditCourseScreen({super.key, required this.course});

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  late String _title;
  late int _credits;
  late String _status;

  @override
  void initState() {
    super.initState();
    _title = widget.course.title;
    _credits = widget.course.credits;
    _status = widget.course.status;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final updatedCourse = Course(
      id: widget.course.id,
      code: widget.course.code, 
      title: _title,
      credits: _credits,
      status: _status,
    );

    final provider = context.read<CourseProvider>();
    final success = await provider.updateCourse(widget.course.id ?? 1, updatedCourse);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course berhasil diperbarui!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${provider.error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text('Oleh: $studentName ($studentId)', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: widget.course.code,
              readOnly: true, 
              decoration: const InputDecoration(
                labelText: 'Kode Course (Read-Only)', 
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black12,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Judul Course', border: OutlineInputBorder()),
              validator: (value) => value == null || value.isEmpty ? 'Judul wajib diisi' : null,
              onSaved: (value) => _title = value!,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _credits.toString(),
              decoration: const InputDecoration(labelText: 'Jumlah SKS', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) return 'SKS wajib diisi';
                if (int.tryParse(value) == null) return 'SKS harus berupa angka';
                return null;
              },
              onSaved: (value) => _credits = int.parse(value!),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'planned', child: Text('Planned')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitForm,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Perbarui Course', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}