import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'manage_doctor_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

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
    children: const [
      _StatCard(title: 'Total Dokter', value: '6', color: Colors.blue),
      _StatCard(title: 'Praktik hari ini', value: '10', color: Colors.green),
      _StatCard(title: 'Total Pasien', value: '5', color: Colors.red),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageDoctorPage()),
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
  final doctors = [
    {'name': 'Dr. Floyd Miles', 'specialist': 'Pediatrics'},
    {'name': 'Dr. Guy Hawkins', 'specialist': 'Dentist'},
    {'name': 'Dr. Jane Cooper', 'specialist': 'Cardiologist'},
    {'name': 'Dr. Jacob Jones', 'specialist': 'Nephrologyst'},
  ];

  return ListView.separated(
    itemCount: doctors.length,
    separatorBuilder: (_, __) => const SizedBox(height: 12),
    itemBuilder: (context, index) {
      final doctor = doctors[index];
      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 1,
        child: ListTile(
          leading: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/doctor1.png'),
          ),
          title: Text(doctor['name']!),
          subtitle: Text(doctor['specialist']!),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Edit Dokter
          },
        ),
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
