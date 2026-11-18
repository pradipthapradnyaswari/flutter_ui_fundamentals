
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _logoutRed = Color(0xFFDC2626);
  static const Color _secondaryTextColor = Color(0xFF64748B);

  late Future<UserProfile?> _profileFuture;

  bool _isUploadingAvatar = false;

  final ImagePicker _imagePicker = ImagePicker();
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _profileFuture = _profileService.getMyProfile();
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = _profileService.getMyProfile();
    });
  }

  Future<void> _changeProfilePhoto() async {
    if (_isUploadingAvatar) return;

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedImage == null || !mounted) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      await _profileService.uploadAvatar(pickedImage);

      if (!mounted) return;

      setState(() {
        _profileFuture = _profileService.getMyProfile();
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isUploadingAvatar = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah foto profil: $e'),
          backgroundColor: _logoutRed,
        ),
      );
    }
  }

  Future<void> _editProfile(UserProfile profile) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditProfileDialog(profile: profile),
    );

    if (result != true || !mounted) return;

    await _refreshProfile();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil berhasil diperbarui.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Logout',
          style: TextStyle(color: _darkBlue),
        ),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: _secondaryTextColor,
            ),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: _logoutRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !context.mounted) return;

    try {
      await AuthService.instance.logout();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout. Silakan coba lagi.'),
        ),
      );
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'student':
        return 'Mahasiswa';
      case 'lecturer':
        return 'Dosen';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  String _getIdentityLabel(UserProfile profile) {
    if (profile.identityType?.trim().isNotEmpty == true) {
      return profile.identityType!.toUpperCase();
    }

    if (profile.isStudent) return 'NIM';
    if (profile.isLecturer) return 'NIP/NIDN';

    return 'Nomor Identitas';
  }

  Widget _buildAvatar(UserProfile profile) {
    final avatarUrl = profile.avatarUrl?.trim() ?? '';

    return Stack(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: const Color(0xFFEFF6FF),
          child: avatarUrl.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 55,
                  color: _primaryBlue,
                )
              : ClipOval(
                  child: Image.network(
                    avatarUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 55,
                        color: _primaryBlue,
                      );
                    },
                  ),
                ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: _primaryBlue,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: _isUploadingAvatar ? null : _changeProfilePhoto,
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 34,
                height: 34,
                child: Center(
                  child: _isUploadingAvatar
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          size: 18,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: _primaryBlue,
      ),
      title: Text(title),
      subtitle: Text(value),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    final displayName =
        profile.name.trim().isEmpty ? 'Pengguna' : profile.name;

    final displayEmail = profile.email.isEmpty
        ? AuthService.instance.currentUser?.email ?? '-'
        : profile.email;

    final identityNumber = profile.identityNumber?.trim() ?? '';
    final studyProgram = profile.studyProgram?.trim() ?? '';
    final faculty = profile.faculty?.trim() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildAvatar(profile),

        const SizedBox(height: 16),

        Text(
          displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),

        const SizedBox(height: 6),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getRoleName(profile.role),
            style: const TextStyle(
              color: _primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Ketuk ikon kamera untuk mengubah foto profil',
          style: TextStyle(
            color: _secondaryTextColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),

        const Divider(
          height: 32,
          color: Color(0xFFCBD5E1),
        ),

        _buildInfoTile(
          icon: Icons.email,
          title: 'Email',
          value: displayEmail,
        ),

        if (identityNumber.isNotEmpty)
          _buildInfoTile(
            icon: Icons.badge,
            title: _getIdentityLabel(profile),
            value: identityNumber,
          ),

        if (profile.isStudent && studyProgram.isNotEmpty)
          _buildInfoTile(
            icon: Icons.school,
            title: 'Program Studi',
            value: studyProgram,
          ),

        if (profile.isLecturer && studyProgram.isNotEmpty)
          _buildInfoTile(
            icon: Icons.school,
            title: 'Homebase',
            value: studyProgram,
          ),

        if (faculty.isNotEmpty)
          _buildInfoTile(
            icon: Icons.account_balance,
            title: 'Fakultas',
            value: faculty,
          ),

        _buildInfoTile(
          icon: Icons.verified_user,
          title: 'Role',
          value: _getRoleName(profile.role),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _editProfile(profile),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profil'),
            style: FilledButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _logoutRed,
              side: const BorderSide(color: _logoutRed),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<UserProfile?>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _primaryBlue,
                  ),
                ),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                child: Text('Gagal memuat profil'),
              );
            }

            return _buildProfileInfo(snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserProfile profile;

  const _EditProfileDialog({
    required this.profile,
  });

  @override
  State<_EditProfileDialog> createState() =>
      _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _identityController;
  late final TextEditingController _studyProgramController;
  late final TextEditingController _facultyController;

  bool _isSaving = false;
  String? _errorMessage;

  UserProfile get profile => widget.profile;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: profile.name);
    _identityController =
        TextEditingController(text: profile.identityNumber ?? '');
    _studyProgramController =
        TextEditingController(text: profile.studyProgram ?? '');
    _facultyController =
        TextEditingController(text: profile.faculty ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    _studyProgramController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final identityType = profile.isStudent
          ? 'NIM'
          : profile.isLecturer
              ? (profile.identityType?.trim().isNotEmpty == true
                  ? profile.identityType!.trim()
                  : 'NIP/NIDN')
              : null;

      await ProfileService().updateMyProfile(
        name: _nameController.text,
        identityType: identityType,
        identityNumber:
            profile.isAdmin ? null : _identityController.text,
        studyProgram:
            profile.isAdmin ? null : _studyProgramController.text,
        faculty: profile.isAdmin ? null : _facultyController.text,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _errorMessage = 'Gagal menyimpan profil. Silakan coba lagi.';
      });
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: _primaryBlue,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = profile.isStudent;
    final isLecturer = profile.isLecturer;
    final hasIdentityFields = isStudent || isLecturer;

    final identityLabel = isStudent
        ? 'NIM'
        : profile.identityType?.trim().isNotEmpty == true
            ? profile.identityType!
            : 'NIP/NIDN';

    return AlertDialog(
      title: const Text(
        'Edit Profil',
        style: TextStyle(
          color: _darkBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  label: 'Nama Lengkap',
                  controller: _nameController,
                  hint: 'Masukkan nama lengkap',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),

                if (hasIdentityFields) ...[
                  _buildTextField(
                    label: identityLabel,
                    controller: _identityController,
                    hint: 'Masukkan nomor identitas',
                  ),

                  _buildTextField(
                    label: isStudent ? 'Program Studi' : 'Homebase',
                    controller: _studyProgramController,
                    hint: isStudent
                        ? 'Masukkan program studi'
                        : 'Masukkan homebase',
                  ),

                  _buildTextField(
                    label: 'Fakultas',
                    controller: _facultyController,
                    hint: 'Masukkan fakultas',
                  ),
                ],

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed:
              _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: FilledButton.styleFrom(
            backgroundColor: _primaryBlue,
            foregroundColor: Colors.white,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}
