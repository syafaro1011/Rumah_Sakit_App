import 'package:flutter/material.dart';
import 'doctor_list_page.dart';

class PilihPoliPage extends StatelessWidget {
  const PilihPoliPage({super.key});

  // Data statis untuk UI (Icon dan Warna)
  static final List<Map<String, dynamic>> poliList = [
    {
      'name': 'Poli Umum',
      'icon': Icons.local_hospital_outlined,
      'color': const Color(0xFFEAF1FF),
    },
    {
      'name': 'Poli Gigi',
      'icon': Icons.medical_services_outlined,
      'color': const Color(0xFFFFF4DB),
    },
    {
      'name': 'Poli Saraf',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFFE8F5E9),
    },
    {
      'name': 'Poli Anak',
      'icon': Icons.child_friendly_outlined,
      'color': const Color(0xFFFFE9E4),
    },
    {
      'name': 'Poli Mata',
      'icon': Icons.remove_red_eye_outlined,
      'color': const Color(0xFFE3F2FD),
    },
    {
      'name': 'Poli THT',
      'icon': Icons.hearing_outlined,
      'color': const Color(0xFFF3E5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pilih Spesialisasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      // Menggunakan ListView agar bisa scroll jika jumlah poli bertambah banyak
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: poliList.length,
        itemBuilder: (context, index) {
          final poli = poliList[index];
          return _poliCard(
            context: context,
            icon: poli['icon'],
            title: poli['name'],
            bgColor: poli['color'],
          );
        },
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ================= COMPONENT =================

  Widget _poliCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorListPage(
                  // 🔥 DISESUAIKAN: Parameter di DoctorListPage adalah 'poliName'
                  poliName: title,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 26, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: const Color(0xFF3F6DF6),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Jadwal',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}
