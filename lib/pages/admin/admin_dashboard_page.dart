import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rumahsakitapp/services/admin_service.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminService _adminService = AdminService();

  String _searchQuery = ''; // Tambahkan state untuk pencarian

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
              // Gunakan Expanded agar list tidak overflow
              Expanded(child: _doctorList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'ADMIN',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        SizedBox(height: 4),
        Text('Atur Dokter dan Jadwal', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _statSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        StreamBuilder<int>(
          stream: _adminService.getDoctorsCount(),
          builder: (context, snapshot) => _StatCard(
            title: 'Total Dokter',
            value: snapshot.data?.toString() ?? '0', // Tambahkan null-safety
            color: Colors.blue,
          ),
        ),
        StreamBuilder<int>(
          stream: _adminService.getTodayPraktikCount(),
          builder: (context, snapshot) => _StatCard(
            title: 'Praktik Hari Ini',
            value: snapshot.data?.toString() ?? '0',
            color: Colors.green,
          ),
        ),
        StreamBuilder<int>(
          stream: _adminService.getCountByRole('pasien'),
          builder: (context, snapshot) => _StatCard(
            title: 'Total Pasien',
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
        hintText: 'Cari Dokter..',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
          return const Center(child: Text("Belum ada data dokter"));
        }

        // Filter pencarian
        final docs = snapshot.data!.docs.where((doc) {
          final name = (doc.data() as Map<String, dynamic>)['nama']?.toString().toLowerCase() ?? '';
          return name.contains(_searchQuery.toLowerCase());
        }).toList();

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;
            
            // Ambil data dengan aman (mencegah error bad state)
            String nama = data['nama'] ?? 'Tanpa Nama';
            String poli = data['poli'] ?? 'Umum';
            String? photoUrl = data['photoUrl'];

            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 1,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFEAF1FF),
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person, color: Colors.blue) : null,
                ),
                title: Text(nama, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(poli),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  final doctor = DoctorModel(
                    id: docs[index].id,
                    nama: nama,
                    poli: poli,
                    sip: data['no_SIP'] ?? '',
                    email: data['email'] ?? '',
                    password: '', // Password tidak diambil dari Firestore
                    phone: data['no_hp'] ?? '',
                    experience: data['experience'] ?? '',
                    isActive: (data['status'] ?? 'nonaktif') == 'aktif',
                    schedules: [], // Jadwal bisa diambil di halaman profil jika diperlukan
                    photoUrl: photoUrl,
                  );
                  // Navigasi ke halaman profil dokter (DoctorProfilePage)
                  Navigator.pushNamed(
                    context,
                    AppRoutes.doctorProfile,
                    arguments: doctor, // 'doctor' di sini adalah objek DoctorModel
  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// Komponen Card Statistik yang dipisahkan agar kode bersih
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
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

// Tombol Kelola Dokter (Pindah ke bawah agar rapi)
Widget _kelolaDokterCard(BuildContext context) {
  return Material(
    color: const Color(0xFF3F6DF6), // Beri warna biru agar menonjol sebagai tombol utama
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.manageDoctor),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.stethoscope, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Kelola Dokter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Tambah, Edit, & Jadwal', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    ),
  );
}

Widget _bottomNav() {
  return BottomNavigationBar(
    showSelectedLabels: false,
    showUnselectedLabels: false,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notif'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ],
  );
}