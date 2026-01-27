import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:rumahsakitapp/services/admin_service.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {

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
              Expanded(child: _doctorList()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }
}

Widget _header() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: const [
      Text(
        'ADMIN',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        stream: AdminService().getCountByRole('dokter'),
        builder: (context, snapshot) => _StatCard(
          title: 'Total Dokter',
          value: snapshot.data.toString(),
          color: Colors.blue,
        ),
      ),
      StreamBuilder<int>(
        stream: AdminService().getTodayPraktikCount(),
        builder: (context, snapshot) => _StatCard(
          title: 'Praktik Hari Ini',
          value: snapshot.data.toString(),
          color: Colors.green,
        ),
      ),
      StreamBuilder<int>(
        stream: AdminService().getCountByRole('pasien'),
        builder: (context, snapshot) => _StatCard(
          title: 'Total Pasien',
          value: snapshot.data.toString(),
          color: Colors.red,
        ),
      ),  
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _kelolaDokterCard(BuildContext context) {
  return Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    elevation: 2,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.pushNamed(
          context, AppRoutes.manageDoctor,
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(LucideIcons.stethoscope),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Kelola Dokter',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  'CRUD & jadwal',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _searchField() {
  return TextField(
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
      stream: AdminService().getDoctorsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("Belum ada data dokter"));
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var doctor = docs[index].data() as Map<String, dynamic>;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 1,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF1FF),
                  child: Icon(Icons.person, color: Colors.blue),
                ),
                title: Text(doctor['nama'] ?? 'Tanpa Nama'),
                subtitle: Text(doctor['spesialis'] ?? 'Umum'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Tambahkan logika edit di sini
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
    currentIndex: 0,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(
        icon: CircleAvatar(
          radius: 18,
          child: Icon(Icons.add, color: Colors.white),
        ),
        label: '',
      ),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
    ],
  );
}
