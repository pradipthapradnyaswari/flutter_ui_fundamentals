
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/profile_service.dart';
import '../main.dart' show studentId, studentName;
import 'edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;

  const CourseDetailScreen({
    super.key,
    required this.course,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);

  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Widget _buildStudentLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        '$studentName - $studentId',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus course "${course.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    if (!context.mounted) return;

    final provider = context.read<CourseProvider>();
    final success = await provider.deleteCourse(
      course.id ?? 1,
      course.code,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Course berhasil dihapus!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    final updatedCourse = provider.courses.firstWhere(
      (c) => c.code == widget.course.code,
      orElse: () => widget.course,
    );

    final isFavorite = provider.isFavorite(updatedCourse.code);

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final role = snapshot.data?.role ?? '';
        final canManageCourse =
            !snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done &&
            ['lecturer', 'admin'].contains(role);

        return Scaffold(
          appBar: AppBar(
            title: Text(updatedCourse.title),
            backgroundColor: _darkBlue,
            foregroundColor: Colors.white,
            actions: [
              if (canManageCourse) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Course',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCourseScreen(course: updatedCourse),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Hapus Course',
                  onPressed: () =>
                      _confirmDelete(context, updatedCourse),
                ),
              ],
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStudentLabel(),
                Text(
                  updatedCourse.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kode Mata Kuliah: ${updatedCourse.code}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jumlah SKS: ${updatedCourse.credits}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Status: ${updatedCourse.status.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: updatedCourse.status == 'done'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
                const Divider(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isFavorite ? Colors.red.shade100 : _primaryBlue,
                      foregroundColor:
                          isFavorite ? Colors.red : Colors.white,
                    ),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                    ),
                    label: Text(
                      isFavorite
                          ? 'Hapus dari Favorit'
                          : 'Tandai sebagai Favorit',
                    ),
                    onPressed: () async {
  try {
    await context
        .read<CourseProvider>()
        .toggleFavorite(updatedCourse.code);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gagal memperbarui favorit: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
