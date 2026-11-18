
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color _primaryBlue = Color(0xFF2563EB);
  static const Color _darkBlue = Color(0xFF1E40AF);
  static const Color _lightBlue = Color(0xFFEFF6FF);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _identityNumberController = TextEditingController();

  String _role = 'student';
  String _identityType = 'NIP';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _identityNumberController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await AuthService.instance.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _role,
        identityType: _role == 'student' ? 'NIM' : _identityType,
        identityNumber: _identityNumberController.text.trim(),
      );

      if (!mounted) return;

      if (response.session != null) {
        await AuthService.instance.logout();

        if (!mounted) return;

        _showMessage('Registrasi berhasil! Silakan login.');
        Navigator.of(context).pop();
      } else {
        _showMessage(
          'Registrasi berhasil. Silakan periksa email Anda.',
        );

        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: _primaryBlue),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _lightBlue.withValues(alpha: 0.45),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _primaryBlue,
          width: 1.8,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildIdentityField() {
    if (_role == 'student') {
      return TextFormField(
        controller: _identityNumberController,
        keyboardType: TextInputType.number,
        decoration: _inputDecoration(
          label: 'NIM',
          hint: 'Masukkan Nomor Induk Mahasiswa',
          icon: Icons.badge_outlined,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'NIM wajib diisi';
          }
          return null;
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          initialValue: _identityType,
          decoration: _inputDecoration(
            label: 'Jenis Identitas',
            icon: Icons.badge_outlined,
          ),
          items: const [
            DropdownMenuItem(
              value: 'NIP',
              child: Text('NIP'),
            ),
            DropdownMenuItem(
              value: 'NIDN',
              child: Text('NIDN'),
            ),
            DropdownMenuItem(
              value: 'NUPTK',
              child: Text('NUPTK'),
            ),
          ],
          onChanged: _isLoading
              ? null
              : (value) {
                  if (value != null) {
                    setState(() {
                      _identityType = value;
                    });
                  }
                },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _identityNumberController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(
            label: _identityType,
            hint: 'Masukkan nomor $_identityType',
            icon: Icons.numbers,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nomor $_identityType wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _lightBlue,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 52,
                      color: _primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),

                  const Text(
                    'Daftar untuk mengakses Learning Dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration(
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: _inputDecoration(
                      label: 'Daftar sebagai',
                      icon: Icons.badge_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'student',
                        child: Text('Mahasiswa'),
                      ),
                      DropdownMenuItem(
                        value: 'lecturer',
                        child: Text('Dosen'),
                      ),
                    ],
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            setState(() {
                              _role = value ?? 'student';
                              _identityNumberController.clear();
                            });
                          },
                  ),
                  const SizedBox(height: 18),

                  _buildIdentityField(),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration(
                      label: 'Email',
                      icon: Icons.email_outlined,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email wajib diisi';
                      }

                      if (!RegExp(
                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                      ).hasMatch(value.trim())) {
                        return 'Format email tidak valid';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration(
                      label: 'Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _primaryBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password wajib diisi';
                      }

                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration(
                      label: 'Konfirmasi Password',
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: _primaryBlue,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }

                      if (value != _passwordController.text) {
                        return 'Password tidak sama';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  FilledButton(
                    onPressed: _isLoading ? null : _register,
                    style: FilledButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _primaryBlue.withValues(
                        alpha: 0.5,
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
