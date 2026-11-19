
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    final data = await supabase
        .from('courses')
        .select()
        .order('id');

    return (data as List)
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Course> createCourse(Course course) async {
    final row = await supabase
        .from('courses')
        .insert(course.toJson())
        .select()
        .single();

    return Course.fromJson(row);
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    await supabase
        .from('courses')
        .update(course.toJson())
        .eq('id', id);
  }

  @override
  Future<void> deleteCourse(int id) async {
    await supabase
        .from('courses')
        .delete()
        .eq('id', id);
  }

  @override
  Future<List<String>> getFavorites() async {
    final data = await supabase
        .from('course_favorites')
        .select('course_code');

    return (data as List)
        .map((item) => item['course_code'] as String)
        .toList();
  }

  @override
  Future<void> addFavorite(String courseCode) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Pengguna belum login.');
    }

    await supabase.from('course_favorites').insert({
      'user_id': userId,
      'course_code': courseCode,
    });
  }

  @override
  Future<void> removeFavorite(String courseCode) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Pengguna belum login.');
    }

    await supabase
        .from('course_favorites')
        .delete()
        .eq('user_id', userId)
        .eq('course_code', courseCode);
  }
}
