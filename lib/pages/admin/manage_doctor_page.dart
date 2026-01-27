import 'package:flutter/material.dart';
import '../../model/doctor_model.dart';
import 'doctor_form_page.dart';

class ManageDoctorPage extends StatefulWidget {
  const ManageDoctorPage({super.key});

  @override
  State<ManageDoctorPage> createState() => _ManageDoctorPageState();
}

class _ManageDoctorPageState extends State<ManageDoctorPage> {
  final List<DoctorModel> doctors = [
    DoctorModel(
      id: '1',
      name: 'Dr. FUFUFAFA',
      poli: 'Poli Gigi',
      sip: '1232141234',
      email: 'fufufafa@example.com',
      phone: '0821321324215',
      experience: '10 Tahun',
      isActive: true,
      schedules: [
        DoctorSchedule(
          day: 'Senin',
          start: const TimeOfDay(hour: 8, minute: 0),
          end: const TimeOfDay(hour: 13, minute: 0),
        ),
        DoctorSchedule(
          day: 'Kamis',
          start: const TimeOfDay(hour: 15, minute: 0),
          end: const TimeOfDay(hour: 20, minute: 0),
        ),
      ],
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Stone',
      poli: 'Poli Saraf',
      sip: '1232141234',
      email: 'stone@example.com',
      phone: '0821321324215',
      experience: '8 Tahun',
      isActive: false,
      schedules: [
        DoctorSchedule(
          day: 'Selasa',
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 14, minute: 0),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: _buildAppBar(),
      body: Column(
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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorFormPage()),
            );

            if (result != null) {
              setState(() => doctors.add(result));
            }
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
          /// HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  doctor.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              Switch(
                value: doctor.isActive,
                activeColor: Colors.green,
                onChanged: (value) {
                  setState(() => doctor.isActive = value);
                },
              ),
            ],
          ),
          Text(doctor.poli, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(
            'SIP - ${doctor.sip}',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),

          const Divider(height: 28),

          _infoRow(Icons.email_outlined, 'Email', doctor.email),
          _infoRow(Icons.phone_outlined, 'No. Telpon', doctor.phone),
          _infoRow(
            Icons.calendar_today_outlined,
            'Jadwal Praktik',
            _formatSchedule(doctor.schedules),
          ),

          const SizedBox(height: 14),

          /// ACTION
          Row(
            children: [
              _iconButton(
                icon: Icons.edit_outlined,
                color: Colors.grey.shade200,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorFormPage(initialDoctor: doctor),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      final index = doctors.indexOf(doctor);
                      doctors[index] = result;
                    });
                  }
                },
              ),
              const SizedBox(width: 10),
              _iconButton(
                icon: Icons.delete_outline,
                color: Colors.red.shade100,
                iconColor: Colors.red,
                onTap: () => _deleteDoctor(doctor),
              ),
              const Spacer(),
              _statusBadge(doctor.isActive),
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSchedule(List<DoctorSchedule> schedules) {
    return schedules
        .map((s) {
          return '${s.day}: ${s.start.format(context)} - ${s.end.format(context)}';
        })
        .join('\n');
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

  void _deleteDoctor(DoctorModel doctor) {
    setState(() => doctors.remove(doctor));
  }
}
