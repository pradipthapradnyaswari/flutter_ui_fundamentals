import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';
import '../main.dart' show studentId, studentName;
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus course "${course.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false), 
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true), 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!context.mounted) return; 

    final provider = context.read<CourseProvider>();
    final success = await provider.deleteCourse(course.id ?? 1, course.code);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course berhasil dihapus!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${provider.error}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    final updatedCourse = provider.courses.firstWhere(
      (c) => c.code == course.code, 
      orElse: () => course, 
    );
    
    final isFavorite = provider.isFavorite(updatedCourse.code);

    return Scaffold(
      appBar: AppBar(
        title: Text(updatedCourse.title), 
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCourseScreen(course: updatedCourse), 
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId\n$studentName',
              style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Text(
              updatedCourse.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Kode Mata Kuliah: ${updatedCourse.code}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Jumlah SKS: ${updatedCourse.credits}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Status: ${updatedCourse.status.toUpperCase()}', 
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.bold,
                color: updatedCourse.status == 'done' ? Colors.green : Colors.orange,
              ),
            ),
            const Divider(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFavorite ? Colors.red.shade100 : Colors.blue,
                  foregroundColor: isFavorite ? Colors.red : Colors.white,
                ),
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                label: Text(isFavorite ? 'Hapus dari Favorit' : 'Tandai sebagai Favorit'),
                onPressed: () {
                  context.read<CourseProvider>().toggleFavorite(updatedCourse.code);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}