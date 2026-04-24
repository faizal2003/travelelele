import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'driver_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
//login
class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedGender = 'Laki-laki';
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;//visibel password

  void _submit() async { // ambil input
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String name = _nameController.text.trim();

    // validasi format email
    final bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

    //pesan kesalahan
    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      _showError("Mohon lengkapi semua data");
      return;
    }

    if (!isEmailValid) {
      _showError("Format email tidak valid");
      return;
    }

    if (password.length < 6) {
      _showError("Password minimal 6 karakter");
      return;
    }
    //memproses login
    setState(() => _isLoading = true);
    String? result;

    if (_isLogin) {
      // menangani login dalam memverifikasi email dan password melalui metode signIn dari AuthService
      result = await _authService.signIn(
        email: email,
        password: password,
      );
      //pilihan login
      if (result == 'Customer' || result == 'Driver' || result == 'Admin') {
        _navigateBasedOnRole(result!);
      } else {
        _showError(result ?? "Login failed");
      }
    } else {
      // jika belum daftar
      result = await _authService.signUp(
        email: email,
        password: password,
        role: 'Customer',
        name: name,
        gender: _selectedGender,
      );
      //menghentikan proses ketika pengguna salah
      if (result == null) {
        _navigateBasedOnRole('Customer');
      } else {
        _showError(result);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  //sinkronisasi lupa password
  void _forgotPassword() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError("Masukkan email untuk reset password");
      return;
    }

    // validasi email
    final bool isEmailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    if (!isEmailValid) {
      _showError("Format email tidak valid");
      return;
    }
    //reset password
    setState(() => _isLoading = true);
    final String? result = await _authService.resetPassword(email);
    setState(() => _isLoading = false);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email reset password telah dikirim"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showError(result);
    }
  }
  //navigasi berdasarkan role
  void _navigateBasedOnRole(String role) {
    Widget nextScreen;
    if (role == 'Admin') {
      nextScreen = const AdminDashboard();
    } else if (role == 'Driver') {
      nextScreen = const DriverDashboard();
    } else {
      nextScreen = const HomeScreen();
    }
    //nemeruskan slide sesuai role
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }
  //jika ada kesalahan
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  //menampilkan halaman login ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('lib/images/logo_new.png', height: 120),
                  const SizedBox(height: 16),
                  const Text("SVARGADWIPA",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        // Toggle Tabs
                        Row(children: [_buildTab("Masuk", true), _buildTab("Daftar", false)]),
                        const SizedBox(height: 24),

                        // Registration Fields
                        if (!_isLogin) ...[
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(labelText: "Nama Lengkap", prefixIcon: Icon(Icons.person)),
                          ),
                          const SizedBox(height: 16),
                          _buildGenderSelection(),
                          const SizedBox(height: 16),
                        ],

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        if (_isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _isLoading ? null : _forgotPassword,
                              child: const Text("Lupa Password?"),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submit,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(_isLogin ? "Masuk" : "Daftar"),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //tambahan gender pada pendaftaran
  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender", style: TextStyle(color: Colors.grey)),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text("L", style: TextStyle(fontSize: 14)),
                leading: Radio<String>(
                  value: 'Laki-laki',
                  groupValue: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value!),
                ),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text("P", style: TextStyle(fontSize: 14)),
                leading: Radio<String>(
                  value: 'Perempuan',
                  groupValue: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //login/register ui
  Widget _buildTab(String title, bool isLoginTab) {
    bool active = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = isLoginTab),
        child: Column(
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: active ? Theme.of(context).primaryColor : Colors.grey)),
            const SizedBox(height: 8),
            Container(height: 3, color: active ? Theme.of(context).primaryColor : Colors.transparent)
          ],
        ),
      ),
    );
  }
}