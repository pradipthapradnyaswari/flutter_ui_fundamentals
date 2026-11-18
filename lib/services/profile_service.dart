
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? identityType;
  final String? identityNumber;
  final String? studyProgram;
  final String? faculty;
  final String? avatarUrl;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.identityType,
    this.identityNumber,
    this.studyProgram,
    this.faculty,
    this.avatarUrl,
  });

  bool get isStudent => role == 'student';
  bool get isLecturer => role == 'lecturer';
  bool get isAdmin => role == 'admin';

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      identityType: map['identity_type'] as String?,
      identityNumber: map['identity_number'] as String?,
      studyProgram: map['study_program'] as String?,
      faculty: map['faculty'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<UserProfile?> getMyProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return data == null ? null : UserProfile.fromMap(data);
  }

  Future<String> uploadAvatar(XFile image) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final bytes = await image.readAsBytes();
    final originalExtension = image.name.split('.').last.toLowerCase();

    final extension = ['jpg', 'jpeg', 'png', 'webp']
            .contains(originalExtension)
        ? originalExtension
        : 'jpg';

    final contentType = switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };

    final filePath =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _client.storage.from('avatars').uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: contentType,
            upsert: false,
          ),
        );

    final publicUrl =
        _client.storage.from('avatars').getPublicUrl(filePath);

    await _client
        .from('profiles')
        .update({'avatar_url': publicUrl})
        .eq('id', user.id);

    return publicUrl;
  }

  Future<void> updateMyProfile({
    required String name,
    String? identityType,
    String? identityNumber,
    String? studyProgram,
    String? faculty,
  }) async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    final updates = <String, dynamic>{
      'name': name.trim(),
    };

    if (identityType != null) {
      updates['identity_type'] = identityType.trim();
    }

    if (identityNumber != null) {
      updates['identity_number'] = identityNumber.trim();
    }

    if (studyProgram != null) {
      updates['study_program'] = studyProgram.trim();
    }

    if (faculty != null) {
      updates['faculty'] = faculty.trim();
    }

    await _client
        .from('profiles')
        .update(updates)
        .eq('id', user.id);
  }
}
