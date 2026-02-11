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

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLogin = true;
  bool _isLoading = false;

  void _submit() async {
    setState(() => _isLoading = true);
    String? result;

    if (_isLogin) {
      // --- LOGIN FLOW (Unchanged) ---
      // 1. User logs in
      // 2. App checks Firestore for their role (Customer, Driver, or Admin)
      // 3. App navigates them to the correct screen
      result = await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (result == 'Customer' || result == 'Driver' || result == 'Admin') {
        _navigateBasedOnRole(result!);
      } else {
        _showError(result ?? "Login failed");
      }
    } else {
      // --- REGISTER FLOW (Updated) ---
      // We FORCE the role to be 'Customer' here.
      result = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'Customer', // <--- HARDCODED SECURITY
        name: _nameController.text.trim(),
      );

      if (result == null) {
        // Registration success -> Go to Customer Home
        _navigateBasedOnRole('Customer');
      } else {
        _showError(result);
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _navigateBasedOnRole(String role) {
    Widget nextScreen;
    if (role == 'Admin') {
      nextScreen = const AdminDashboard();
    } else if (role == 'Driver') {
      nextScreen = const DriverDashboard();
    } else {
      nextScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

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
                  const Icon(Icons.flight_takeoff, size: 80, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text("Smart Travel",
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
                          // NOTE: The Role Dropdown is GONE.
                        ],

                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
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