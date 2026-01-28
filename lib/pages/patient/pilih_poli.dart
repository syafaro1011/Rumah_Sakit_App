import 'package:flutter/material.dart';
import 'doctor_list_page.dart';

class PilihPoliPage extends StatelessWidget {
  const PilihPoliPage({super.key});

  // 🔥 SUMBER POLI (SATU PINTU)
  static final List<Map<String, dynamic>> poliList = [
    {
      'name': 'Poli Umum',
      'icon': Icons.local_hospital_outlined,
      'color': Color(0xFFEAF1FF),
    },
    {
      'name': 'Poli Gigi',
      'icon': Icons.medical_services_outlined,
      'color': Color(0xFFFFF4DB),
    },
    {
      'name': 'Poli Saraf',
      'icon': Icons.psychology_outlined,
      'color': Color(0xFFE8F5E9),
    },
    {
      'name': 'Poli Anak',
      'icon': Icons.child_friendly_outlined,
      'color': Color(0xFFFFE9E4),
    },
    {
      'name': 'Poli Mata',
      'icon': Icons.remove_red_eye_outlined,
      'color': Color(0xFFE3F2FD),
    },
    {
      'name': 'Poli THT',
      'icon': Icons.hearing_outlined,
      'color': Color(0xFFF3E5F5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Poli',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      bottomNavigationBar: _bottomNav(),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔥 LIST POLI DINAMIS
            ...poliList.map(
              (poli) => _poliCard(
                icon: poli['icon'],
                title: poli['name'],
                bgColor: poli['color'],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorListPage(
                        poli: poli['name'], // 🔥 INI YANG DIPAKAI QUERY
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= COMPONENT =================

  Widget _poliCard({
    required IconData icon,
    required String title,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav() {
    return const BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.home_outlined, color: Colors.grey),
            Icon(Icons.person_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
