import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/doctor_model.dart';
import '../../services/admin_service.dart';
import 'doctor_form_page.dart';
import 'doctor_profile_page.dart';

class ManageDoctorPage extends StatefulWidget {
  const ManageDoctorPage({super.key});

  @override
  State<ManageDoctorPage> createState() => _ManageDoctorPageState();
}

class _ManageDoctorPageState extends State<ManageDoctorPage> {
  final AdminService adminService = AdminService();

  // ================= MAP DOCTOR =================

  Future<List<DoctorModel>> mapDoctors(QuerySnapshot snapshot) async {
    List<DoctorModel> doctors = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final jadwalSnapshot =
          await adminService.getJadwalDokter(doc.id).first;

      final schedules = jadwalSnapshot.docs.map((j) {
        final jd = j.data() as Map<String, dynamic>;
        return DoctorSchedule(
          day: jd['hari'] ?? '',
          start: _parseTime(jd['jam_mulai']),
          end: _parseTime(jd['jam_selesai']),
        );
      }).toList();

      doctors.add(
        DoctorModel(
          id: doc.id,
          nama: data['nama'] ?? '',
          poli: data['poli'] ?? '',
          sip: data['no_str'] ?? '',
          email: data['email'] ?? '',
          password: '',
          phone: data['no_hp'] ?? '',
          experience: data['experience'] ?? '',
          isActive: data['status'] == 'aktif',
          schedules: schedules,
          photoPath: data['photoPath'],
        ),
      );
    }
    return doctors;
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
// Delete Doctor
  Future<void> _deleteDoctor(DoctorModel doctor) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Dokter'),
      content: Text('Yakin ingin menghapus ${doctor.nama}?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirm == true) {
    await adminService.deleteDoctor(doctor.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dokter berhasil dihapus')),
    );
  }
}

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: adminService.getAllDoctors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada dokter'));
          }

          return FutureBuilder<List<DoctorModel>>(
            future: mapDoctors(snapshot.data!),
            builder: (context, doctorSnapshot) {
              if (!doctorSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final doctors = doctorSnapshot.data!;

              return Column(
                children: [
                  _searchBar(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: doctors.length,
                      itemBuilder: (context, index) {
                        return _doctorCard(doctors[index]);
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
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
          onPressed: () async {
            await Navigator.push(
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

  // ================= CARD =================

  Widget _doctorCard(DoctorModel doctor) {
  return InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorProfilePage(doctor: doctor),
        ),
      );
    },
    child: Container(
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
              Expanded(
                child: Text(
                  doctor.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),

              // DELETE
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteDoctor(doctor),
              ),

              // SWITCH AKTIF / NONAKTIF
              Switch(
                value: doctor.isActive,
                onChanged: (value) {
                  adminService.updateStatusDokter(
                    dokterId: doctor.id,
                    status: value ? 'aktif' : 'nonaktif',
                  );
                },
              ),
            ],
          ),

          Text(
            doctor.poli,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const Divider(),

          _infoRow(Icons.email_outlined, 'Email', doctor.email),
          _infoRow(Icons.phone_outlined, 'No. Telpon', doctor.phone),
          _infoRow(
            Icons.calendar_today_outlined,
            'Jadwal',
            _formatSchedule(doctor.schedules),
          ),
        ],
      ),
    ),
  );
}


  
  // ================= HELPERS =================

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text('$title: $value')),
        ],
      ),
    );
  }

  String _formatSchedule(List<DoctorSchedule> schedules) {
    return schedules
        .map((s) =>
            '${s.day} ${s.start.format(context)} - ${s.end.format(context)}')
        .join('\n');
  }
}
