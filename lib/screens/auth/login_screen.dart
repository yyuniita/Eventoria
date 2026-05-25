import 'package:flutter/material.dart';
import 'package:eventoria/core/app_theme.dart';
import 'package:eventoria/screens/home/home_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D14),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              _buildLoginCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned(
            top: -80, left: -60,
            child: _circle(300, AppTheme.primary.withOpacity(0.13)),
          ),
          Positioned(
            top: 40, right: -40,
            child: _circle(200, AppTheme.secondary.withOpacity(0.07)),
          ),
          Positioned(
            top: 160, left: 100,
            child: _circle(120, AppTheme.primary.withOpacity(0.2)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.confirmation_number_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                const Text('EVENTORIA',
                  style: TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w600, letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 6),
                Text('Temukan & nikmati event terbaikmu',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4), fontSize: 13)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pill(Icons.music_note_rounded, 'Konser', AppTheme.primary),
                    const SizedBox(width: 8),
                    _pill(Icons.palette_rounded, 'Pameran', AppTheme.secondary),
                    const SizedBox(width: 8),
                    _pill(Icons.directions_run_rounded, 'Olahraga',
                        const Color(0xFFFF6384)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF16161F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Masuk ke akunmu',
            style: TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Selamat datang kembali! 👋',
            style: TextStyle(
                color: Colors.white.withOpacity(0.4), fontSize: 13)),
          const SizedBox(height: 24),

          _label('Email'),
          _inputField(
            controller: _emailController,
            hint: 'contoh@email.com',
            icon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 16),

          _label('Password'),
          _inputField(
            controller: _passwordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.3), size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text('Lupa password?',
              style: TextStyle(color: AppTheme.primary, fontSize: 12)),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Masuk', style: TextStyle(fontSize: 15)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              children: [
                Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('atau masuk dengan',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 12)),
                ),
                Expanded(
                    child: Divider(color: Colors.white.withOpacity(0.1))),
              ],
            ),
          ),

          Row(
            children: [
              Expanded(child: _socialBtn(
                  Icons.g_mobiledata_rounded, 'Google',
                  const Color(0xFFEA4335))),
              const SizedBox(width: 12),
              Expanded(child: _socialBtn(
                  Icons.apple_rounded, 'Apple', Colors.white)),
            ],
          ),

          const SizedBox(height: 20),
          Center(
            child: RichText(
              text: TextSpan(
                text: 'Belum punya akun? ',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 13),
                children: [
                  TextSpan(
                    text: 'Daftar sekarang',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Helper Widgets ----

  Widget _circle(double size, Color color) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );

  Widget _pill(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
      style: TextStyle(
          color: Colors.white.withOpacity(0.4), fontSize: 12)),
  );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) =>
      Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(icon, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscure,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.25)),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            if (suffix != null) suffix,
          ],
        ),
      );

  Widget _socialBtn(IconData icon, String label, Color iconColor) =>
      Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF0D0D14),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ],
        ),
      );
}