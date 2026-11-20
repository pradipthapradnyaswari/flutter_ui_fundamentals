import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../main.dart' show apiBaseUrl;
import '../models/course.dart';
import '../layouts/compact_layout.dart';
import '../layouts/medium_layout.dart';
import '../layouts/expanded_layout.dart';
import '../services/profile_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);

  final List<Course> _apiCourses = [];

  final ProfileService _profileService = ProfileService();

  late Future<UserProfile?> _profileFuture;

  bool _isLoadingApi = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();

    _profileFuture = _profileService.getMyProfile();

    _loadApiCourses();
  }

  // Mengambil nama role pengguna.
  String _getRoleName(String role) {
    switch (role) {
      case 'student':
        return 'Mahasiswa';
      case 'lecturer':
        return 'Dosen';
      case 'admin':
        return 'Administrator';
      default:
        return 'Pengguna';
    }
  }

  // Mengambil label identitas berdasarkan profil.
  String _getIdentityLabel(UserProfile profile) {
    if (profile.identityType?.trim().isNotEmpty == true) {
      return profile.identityType!.toUpperCase();
    }

    if (profile.isStudent) return 'NIM';
    if (profile.isLecturer) return 'NIP/NIDN';

    return 'Nomor Identitas';
  }

  // Menampilkan foto profil pengguna.
  Widget _buildAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 35,
        backgroundColor: Color(0xFFEFF6FF),
        child: Icon(Icons.person, size: 40, color: _primaryBlue),
      );
    }

    return CircleAvatar(
      radius: 35,
      backgroundColor: const Color(0xFFEFF6FF),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 40, color: _primaryBlue);
          },
        ),
      ),
    );
  }

  // Menampilkan identitas pengguna sesuai role.
  Widget _buildProfileHeader() {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Gagal memuat informasi profil.'),
            ),
          );
        }

        final profile = snapshot.data!;

        final displayName = profile.name.trim().isEmpty
            ? 'Pengguna'
            : profile.name;

        final roleName = _getRoleName(profile.role);

        final identityNumber = profile.identityNumber?.trim() ?? '';

        final avatarUrl = profile.avatarUrl?.trim() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu identitas pengguna.
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildAvatar(avatarUrl),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            identityNumber.isNotEmpty
                                ? '${_getIdentityLabel(profile)}: '
                                      '$identityNumber'
                                : roleName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Selamat Datang di Learning Dashboard!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Informasi aktif berdasarkan role.
            Text(
              identityNumber.isNotEmpty
                  ? '$roleName Aktif: $identityNumber\n'
                        '$displayName'
                  : '$roleName Aktif\n$displayName',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  // GET: Mengambil data course dari REST API.
  Future<void> _loadApiCourses() async {
    setState(() {
      _isLoadingApi = true;
      _apiError = null;
    });

    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/posts'));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final List<dynamic> data = jsonDecode(response.body);

      if (!mounted) return;

      setState(() {
        _apiCourses
          ..clear()
          ..addAll(
            data.map((json) => Course.fromJson(json as Map<String, dynamic>)),
          );
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _apiError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApi = false;
        });
      }
    }
  }

  // Menampilkan dialog tambah atau edit course.
  Future<void> _showCourseDialog({Course? course}) async {
    final result = await showDialog<Course>(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return CourseFormDialog(course: course);
      },
    );

    if (!mounted || result == null) return;

    if (course == null) {
      await _createApiCourse(result);
    } else {
      await _updateApiCourse(result);
    }
  }

  // POST: Menambahkan course melalui REST API.
  Future<void> _createApiCourse(Course course) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/posts'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(course.toJson()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final createdCourse = Course.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );

      if (!mounted) return;

      setState(() {
        _apiCourses.insert(0, createdCourse);
      });

      _showMessage('POST berhasil: course ditambahkan');
    } catch (e) {
      _showMessage('Gagal menambahkan course: $e');
    }
  }

  // PUT: Memperbarui course melalui REST API.
  Future<void> _updateApiCourse(Course course) async {
    try {
      final id = course.id;

      if (id == null) {
        throw Exception('ID course tidak ditemukan');
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/posts/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(course.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      if (!mounted) return;

      setState(() {
        final index = _apiCourses.indexWhere((item) => item.id == id);

        if (index != -1) {
          _apiCourses[index] = course;
        }
      });

      _showMessage('PUT berhasil: course diperbarui');
    } catch (e) {
      _showMessage('Gagal memperbarui course: $e');
    }
  }

  // DELETE: Menghapus course melalui REST API.
  Future<void> _deleteApiCourse(Course course) async {
    final id = course.id;

    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus Course?'),
        content: Text('Yakin ingin menghapus ${course.title}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.delete(Uri.parse('$apiBaseUrl/posts/$id'));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('HTTP ${response.statusCode}');
      }

      if (!mounted) return;

      setState(() {
        _apiCourses.removeWhere((item) => item.id == id);
      });

      _showMessage('DELETE berhasil: course dihapus');
    } catch (e) {
      _showMessage('Gagal menghapus course: $e');
    }
  }

  // Menampilkan pesan menggunakan SnackBar.
  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Tampilan REST API Playground.
  Widget _buildRestApiSection() {
    return Card(
      elevation: 1,
      color: const Color(0xFFEFF6FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.api, color: _primaryBlue, size: 28),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REST API Playground',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _darkBlue,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Pengujian CRUD menggunakan JSONPlaceholder',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: _isLoadingApi ? null : _loadApiCourses,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh data',
                ),
              ],
            ),

            const SizedBox(height: 12),

            const Wrap(
              spacing: 8,
              children: [
                Chip(label: Text('GET')),
                Chip(label: Text('POST')),
                Chip(label: Text('PUT')),
                Chip(label: Text('DELETE')),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoadingApi)
              const Center(child: CircularProgressIndicator())
            else if (_apiError != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gagal mengambil data: $_apiError',
                    style: const TextStyle(color: Colors.red),
                  ),

                  TextButton(
                    onPressed: _loadApiCourses,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              )
            else ...[
              Text(
                'Data API: ${_apiCourses.length} course',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),

              const SizedBox(height: 8),

              ..._apiCourses
                  .take(5)
                  .map(
                    (course) => Card(
                      color: Colors.white,
                      child: ListTile(
                        title: Text(
                          course.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${course.code} • ${course.credits} SKS',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showCourseDialog(course: course);
                            } else if (value == 'delete') {
                              _deleteApiCourse(course);
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Hapus'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              if (_apiCourses.isEmpty) const Text('Belum ada data dari API'),

              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showCourseDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Course API'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),

            const Text(
              'Catatan: JSONPlaceholder merupakan API simulasi. '
              'Perubahan POST, PUT, dan DELETE tidak tersimpan permanen.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),

          const SizedBox(height: 20),

          _buildRestApiSection(),

          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return const CompactLayout();
              } else if (constraints.maxWidth < 900) {
                return const MediumLayout();
              } else {
                return const ExpandedLayout();
              }
            },
          ),
        ],
      ),
    );
  }
}

// Dialog tambah dan edit course.
class CourseFormDialog extends StatefulWidget {
  final Course? course;

  const CourseFormDialog({super.key, this.course});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _codeController;
  late final TextEditingController _titleController;
  late final TextEditingController _creditsController;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController(text: widget.course?.code ?? '');

    _titleController = TextEditingController(text: widget.course?.title ?? '');

    _creditsController = TextEditingController(
      text: widget.course?.credits.toString() ?? '2',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      Course(
        id: widget.course?.id,
        code: _codeController.text.trim(),
        title: _titleController.text.trim(),
        credits: int.parse(_creditsController.text),
        status: widget.course?.status ?? 'planned',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.course == null ? 'Tambah Course API' : 'Edit Course API',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Kode Mata Kuliah',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode wajib diisi';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Mata Kuliah',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah SKS'),
                validator: (value) {
                  final credits = int.tryParse(value ?? '');

                  if (credits == null || credits < 1) {
                    return 'Masukkan jumlah SKS yang valid';
                  }

                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),

        ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
