import 'package:flutter/material.dart';
import 'doctor_model.dart';

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
      schedule: 'Senin: 08:00 - 13:00\nKamis: 15:00 - 20:00',
      isActive: true,
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Stone',
      poli: 'Poli Saraf',
      sip: '1232141234',
      email: 'stone@example.com',
      phone: '0821321324215',
      schedule: 'Senin: 08:00 - 13:00\nKamis: 15:00 - 20:00',
      isActive: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Dokter')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _doctorCard(doctors[index]);
        },
      ),
    );
  }

  // ================= CARD =================

  Widget _doctorCard(DoctorModel doctor) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Switch(
                  value: doctor.isActive,
                  onChanged: (value) {
                    setState(() => doctor.isActive = value);
                  },
                ),
              ],
            ),
            Text(doctor.poli, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 6),
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
              doctor.schedule,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _actionButton(
                  icon: Icons.access_time,
                  label: 'Jadwal',
                  onTap: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _openForm(doctor),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteDoctor(doctor),
                ),
              ],
            ),
            if (doctor.isActive)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(color: Colors.green),
                ),
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

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _openForm(DoctorModel doctor) {
    // TODO: buka form edit
  }

  void _deleteDoctor(DoctorModel doctor) {
    setState(() => doctors.remove(doctor));
  }
}
