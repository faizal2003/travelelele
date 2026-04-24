import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService(); // mengambil nilai teks saat mengedit profil
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false; //edit?
  bool _isLoading = false; //loading?

  //hapus data sebelumnya
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Mengambil teks yang dimasukkan
  void _saveProfile() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();

    //jika masih kosong
    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi semua data"), backgroundColor: Colors.red),
      );
      return;
    }
    //jika tidak memenuhi syarat
    if (name.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama terlalu pendek (min 3 karakter)"), backgroundColor: Colors.red),
      );
      return;
    }
    //no telpon harus 10-13
    if (phone.length < 10 || phone.length > 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nomor telepon tidak valid (10-13 digit)"), backgroundColor: Colors.red),
      );
      return;
    }
    //memperbarui profile
    setState(() => _isLoading = true);

    String? error = await _authService.updateUserProfile(
      name: name,
      phone: phone,
    );

    //memperbarui tampilan
    setState(() {
      _isLoading = false;
      if (error == null) { //periksa error
        _isEditing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile Updated Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      } else { //cek error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    });
  }

  // Logout
  void _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  //menampilkan bagian atas layar Profile judul dan tombol logout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      //menyimpan data firestore
      body: StreamBuilder<DocumentSnapshot>(
        stream: _authService.getUserStream(),
        builder: (context, snapshot) {
          //menangani status koneksi
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          //menangani kesalahan
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading profile"));
          }
          //menangani data tidak ada
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User not found"));
          }

          //ambil data dari firestore
          var userData = snapshot.data!.data() as Map<String, dynamic>;

          //ambil data nama, nomor telpon pada firestore
          if (!_isEditing) {
            _nameController.text = userData['name'] ?? '';
            _phoneController.text = userData['phone'] ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar( //icon lingkaran
                  radius: 50,
                  backgroundColor: Color(0xFF154c79),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  userData['email'] ?? "No Email",
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 32),

                // form profile
                _buildTextField(
                  "Nama Lengkap",
                  _nameController,
                  Icons.person,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Nomor Telpon",
                  _phoneController,
                  Icons.phone,
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(13),
                  ],
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 32),

                // button cancel & save changes
                if (_isEditing)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Save Changes"),
                        ),
                      ),
                    ],
                  )

                  //jika cancel kembali edit profile
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _isEditing = true),
                      child: const Text("Edit Profile"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
    //menerima parameter label, controller, icon, formatters, dan keyboardType menyesuaikan input pengguna
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    List<TextInputFormatter>? formatters,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing, // Disable input if not in edit mode
      inputFormatters: formatters,
      keyboardType: keyboardType,
      textCapitalization: label == "Full Name" ? TextCapitalization.words : TextCapitalization.none,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: !_isEditing,
        fillColor: _isEditing ? Colors.transparent : Colors.grey[100],
      ),
    );
  }
}

