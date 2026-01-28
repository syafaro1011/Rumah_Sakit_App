import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import 'edit_profile_page.dart'; // Pastikan import ini ada

class AdminProfilePage extends StatelessWidget {
  final VoidCallback onSecurityTap;
  final VoidCallback onAboutTap;

  const AdminProfilePage({
    super.key,
    required this.onSecurityTap,
    required this.onAboutTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu muda halus
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: auth.getUserData(user?.uid ?? ""),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var userData = snapshot.data?.data() as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 1. Header Profil (Sesuai Gambar)
                _buildHeaderCard(
                  userData?['nama'] ?? "Admin Rumah Sakit",
                  "ID Admin: #${user?.uid.substring(0, 5).toUpperCase() ?? "000"}",
                ),
                const SizedBox(height: 20),

                // 2. Informasi Pribadi Card
                _buildInfoCard(
                  title: "Informasi Akun",
                  items: [
                    _infoItem(Icons.badge_outlined, "Role Access", userData?['role']?.toUpperCase() ?? "ADMIN"),
                    _infoItem(Icons.email_outlined, "Email Terdaftar", userData?['email'] ?? user?.email ?? "-"),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Pengaturan & Bantuan Card
                _buildInfoCard(
                  title: "Pengaturan & Bantuan",
                  items: [
                    _menuItem(Icons.shield_outlined, "Keamanan Akun", onSecurityTap),
                    _menuItem(Icons.info_outline, "Tentang Aplikasi", onAboutTap),
                  ],
                ),
                const SizedBox(height: 30),

                // 4. Action Buttons
                _buildActionButton(
                  label: "Edit Profile",
                  icon: Icons.edit_outlined,
                  color: const Color(0xFF3F6DF6),
                  onTap: () {
                    // REVISI: Menambahkan navigasi ke EditProfilePage
                    if (userData != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(userData: userData),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  label: "Sign Out",
                  icon: Icons.power_settings_new,
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER TETAP SAMA ---

  Widget _buildHeaderCard(String name, String id) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Color(0xFFEAF1FF),
            child: Icon(Icons.person, size: 50, color: Color(0xFF3F6DF6)),
          ),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(id, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blueAccent, size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Sign Out"),
        content: const Text("Apakah Anda yakin ingin keluar dari sistem?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
            child: const Text("Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}