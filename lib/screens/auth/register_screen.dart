// register_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../core/app_theme.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _role = 'user';
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Validasi format email dengan regex
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    return emailRegex.hasMatch(email);
  }

Future<void> _register() async {
  print('=== TOMBOL DAFTAR DITEKAN ===');

  if (!_formKey.currentState!.validate()) {
    print('=== VALIDASI GAGAL ===');
    return;
  }

  print('=== VALIDASI BERHASIL, KIRIM KE SERVER ===');
  setState(() => _loading = true);

  try {
    final res = await ApiService.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _role,
    );

    print('=== RESPONSE SERVER: $res ===');

    if (res['success'] == true) {
      await ApiService.saveToken(res['token']);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      final errors = res['errors'];
      String msg = res['message'] ?? 'Registrasi gagal';
      if (errors != null) {
        msg = (errors as Map).values.first[0];
      }
      _showError(msg);
    }
  } catch (e) {
    print('=== ERROR: $e ===');
    _showError('Koneksi gagal. Pastikan server berjalan.');
  }

  setState(() => _loading = false);
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppTheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          // ✅ Bungkus dengan Form agar validasi bisa berjalan
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat Akun Baru',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Isi data di bawah untuk mendaftar',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),

                // ✅ Ganti TextField → TextFormField agar bisa pakai validator
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (val.trim().length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!_isValidEmail(val.trim())) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (val.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(
                    labelText: 'Daftar sebagai',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(
                        value: 'organizer', child: Text('Organizer')),
                  ],
                  onChanged: (val) => setState(() => _role = val!),
                ),
                const SizedBox(height: 24),

                // ✅ Tombol full-width dengan SizedBox agar selalu bisa diklik
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _register,
                          child: const Text('Daftar'),
                        ),
                      ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun? '),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}