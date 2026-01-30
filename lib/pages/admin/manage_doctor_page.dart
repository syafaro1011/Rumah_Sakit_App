import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../model/doctor_model.dart';
import '../../services/admin_service.dart';
import 'doctor_form_page.dart';
import '../widgets/admin_bottom_nav.dart';

class ManageDoctorPage extends StatefulWidget {
  const ManageDoctorPage({super.key});

  @override
  State<ManageDoctorPage> createState() => _ManageDoctorPageState();
}

class _ManageDoctorPageState extends State<ManageDoctorPage> {
  final AdminService _adminService = AdminService();
  String _searchQuery = '';

  void _confirmDelete(DoctorModel doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Dokter?'),
        content: Text('Data ${doctor.nama} akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _adminService.deleteDoctor(doctor.id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _adminService.getAllDoctors(), // Mengambil data real-time
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Belum ada data dokter'));
                }

                // Konversi QuerySnapshot menjadi List<DoctorModel>
                final docs = snapshot.data!.docs;

                // Filter pencarian sederhana
                final filteredDocs = docs.where((doc) {
                  final nama = doc['nama'].toString().toLowerCase();
                  return nama.contains(_searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;

                    // Buat model dari data Firestore
                    final doctor = DoctorModel(
                      id: filteredDocs[index].id,
                      nama: data['nama'] ?? '',
                      poli: data['poli'] ?? '',
                      sip: data['no_SIP'] ?? '',
                      email: data['email'] ?? '',
                      password:
                          '', // Password tidak ditarik dari Firestore demi keamanan
                      phone: data['no_hp'] ?? '',
                      experience: data['experience'] ?? '',
                      isActive: data['status'] == 'aktif',
                      photoUrl: data['photoUrl'],
                      schedules: [], // Jadwal biasanya ada di sub-collection
                    );

                    return _doctorCard(doctor);
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
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: const InputDecoration(
          icon: Icon(Icons.search),
          hintText: 'cari dokter',
          border: InputBorder.none,
        ),
      ),
    );
  }

  // ================= CARD =================

  Widget _doctorCard(DoctorModel doctor) {
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
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                backgroundImage: doctor.photoUrl != null
                    ? NetworkImage(doctor.photoUrl!)
                    : null,
                child: doctor.photoUrl == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      doctor.poli,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Switch(
                value: doctor.isActive,
                activeThumbColor: Colors.green,
                onChanged: (value) {
                  _adminService.updateStatusDokter(
                    dokterId: doctor.id,
                    status: value ? 'aktif' : 'nonaktif',
                  );
                },
              ),
            ],
          ),
          const Divider(height: 28),
          _infoRow(Icons.person_outline, 'Nama', doctor.nama),
          _infoRow(Icons.phone_outlined, 'SIP', doctor.sip),
          _infoRow(Icons.medical_services_outlined, 'Spesialis', doctor.poli),
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
                      builder: (_) => DoctorFormPage(initialDoctor: doctor),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              _iconButton(
                icon: Icons.delete_outline,
                color: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () => _confirmDelete(doctor),
              ),
              const Spacer(),
              _statusBadge(doctor.isActive),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(value, style: const TextStyle(fontSize: 12)),
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
        child: Icon(icon, color: iconColor, size: 20),
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
}
