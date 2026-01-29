import 'package:flutter/material.dart';
import 'doctor_list_page.dart';
import '../widgets/patient_bottom_nav.dart';

class PilihPoliPage extends StatelessWidget {
  const PilihPoliPage({super.key});

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
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),

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
                builder: (_) => DoctorListPage(poliName: title),
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
                  child: Icon(icon, size: 26),
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
}
