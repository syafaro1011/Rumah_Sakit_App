import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rumahsakitapp/services/admin_service.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'admin_profile_page.dart'; 
import 'manage_doctor_page.dart';
import 'security_page.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';
  int _currentIndex = 0; // Tambahkan ini untuk mengontrol BottomNav

  // Fungsi untuk menampilkan BottomSheet "Tentang"
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tentang Aplikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Sistem Manajemen Rumah Sakit v1.0.0', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Definisi list halaman
    final List<Widget> pages = [
      _mainDashboardContent(context), 
      const ManageDoctorPage(),       
      AdminProfilePage(
        onSecurityTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SecurityPage())),
        onAboutTap: () => _showAboutSheet(context),
      ),       
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // Mengganti body berdasarkan index BottomNav
      body: pages[_currentIndex], 
      bottomNavigationBar: _bottomNav(),
    );
  }

  // Pindahkan konten dashboard utama ke widget terpisah agar rapi
  Widget _mainDashboardContent(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _statSection(),
            const SizedBox(height: 24),
            _kelolaDokterCard(context),
            const SizedBox(height: 20),
            _searchField(),
            const SizedBox(height: 16),
            const Text("Daftar Dokter", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Expanded(child: _doctorList()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADMIN DASHBOARD',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        SizedBox(height: 4),
        Text('Pantau performa rumah sakit hari ini', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _statSection() {
    return Row(
      children: [
        StreamBuilder<int>(
          stream: _adminService.getDoctorsCount(),
          builder: (context, snapshot) => _StatCard(
            title: 'Total Dokter',
            value: snapshot.data?.toString() ?? '0',
            color: Colors.blue,
          ),
        ),
        StreamBuilder<int>(
          stream: _adminService.getTodayPraktikCount(),
          builder: (context, snapshot) => _StatCard(
            title: 'Praktik Kini',
            value: snapshot.data?.toString() ?? '0',
            color: Colors.green,
          ),
        ),
        StreamBuilder<int>(
          stream: _adminService.getCountByRole('pasien'),
          builder: (context, snapshot) => _StatCard(
            title: 'Pasien',
            value: snapshot.data?.toString() ?? '0',
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _searchField() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Cari dokter spesialis atau nama..',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.zero,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _doctorList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _adminService.getAllDoctors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        final docs = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = data['nama']?.toString().toLowerCase() ?? '';
          final poli = data['poli']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase()) || poli.contains(_searchQuery.toLowerCase());
        }).toList();

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            String nama = data['nama'] ?? 'Dokter';
            String poli = data['poli'] ?? 'Umum';
            String? photoUrl = data['photoUrl'];

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF1FF),
                  backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null || photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.blue) : null,
                ),
                title: Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(poli, style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  final doctor = DoctorModel.fromMap(data, docs[index].id);
                  Navigator.pushNamed(context, AppRoutes.doctorProfile, arguments: doctor);
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: const Color(0xFF3F6DF6),
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(LucideIcons.stethoscope), label: 'Kelola'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}

// Perbaikan widget _StatCard
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 22)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// Tombol Kelola Dokter Utama
Widget _kelolaDokterCard(BuildContext context) {
  return Material(
    color: const Color(0xFF3F6DF6),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.manageDoctor),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.stethoscope, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen Dokter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Atur registrasi dan jadwal rutin', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    ),
  );
}