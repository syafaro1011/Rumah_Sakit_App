import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/admin_service.dart';
import 'doctor_form_page.dart';

class ManageDoctorPage extends StatefulWidget {
  const ManageDoctorPage({super.key});

  @override
  State<ManageDoctorPage> createState() => _ManageDoctorPageState();
}

class _ManageDoctorPageState extends State<ManageDoctorPage> {
  final AdminService _adminService = AdminService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getAllDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada dokter'));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    return _doctorCardFirestore(data, docId);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ================= APP BAR =================

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      leading: const BackButton(),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ADMIN', style: TextStyle(fontSize: 12)),
          Text(
            'Kelola Dokter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorFormPage()),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3F6DF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ================= SEARCH =================

  Widget _searchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'Cari dokter',
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ================= CARD FIRESTORE =================

  Widget _doctorCardFirestore(Map<String, dynamic> doctor, String docId) {
    final bool isActive = doctor['status'] == 'aktif';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  doctor['nama'] ?? '-',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
              Switch(
                value: isActive,
                activeColor: Colors.green,
                onChanged: (value) {
                  _adminService.updateStatusDokter(
                    dokterId: docId,
                    status: value ? 'aktif' : 'nonaktif',
                  );
                },
              ),
            ],
          ),
          Text(doctor['poli'] ?? '-',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            'STR - ${doctor['no_str'] ?? '-'}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),

          const Divider(height: 28),

          _infoRow(Icons.email_outlined, 'Email', doctor['email'] ?? '-'),
          _infoRow(Icons.phone_outlined, 'No. Telpon', doctor['no_hp'] ?? '-'),

          const SizedBox(height: 14),

          Row(
            children: [
              _iconButton(
                icon: Icons.edit_outlined,
                color: Colors.grey.shade200,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorFormPage(
                        doctorId: docId,
                        initialData: doctor,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _iconButton(
                icon: Icons.delete_outline,
                color: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () => _deleteDoctorFirestore(docId),
              ),
              const Spacer(),
              _statusBadge(isActive),
            ],
          ),
        ],
      ),
    );
  }

  // ================= HELPERS =================

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    required Color color,
    Color iconColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _deleteDoctorFirestore(String doctorId) async {
    await _adminService.deleteDoctor(doctorId);
  }
}
