import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import 'package:rumahsakitapp/model/doctor_model.dart';
import 'package:rumahsakitapp/services/admin_service.dart'; // Tambahkan ini

class DoctorProfilePage extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Profil Dokter'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(),
          const SizedBox(height: 20),
          _infoCard(context),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFEAF1FF),
            backgroundImage: doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty
                ? NetworkImage(doctor.photoUrl!)
                : null,
            child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 40, color: Colors.blue)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.nama,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.poli,
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                ),
                Text(
                  'SIP: ${doctor.sip}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Informasi Detail',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              _statusBadge(doctor.isActive),
            ],
          ),
          const Divider(height: 32),
          _infoRow(Icons.email_outlined, 'Email', doctor.email),
          _infoRow(Icons.phone_outlined, 'No. Telepon', doctor.phone),
          _infoRow(Icons.work_outline, 'Pengalaman', '${doctor.experience} Tahun'),
          
          const SizedBox(height: 20),
          const Text(
            'Jadwal Praktik',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
          // UPDATE: MENGGUNAKAN STREAMBUILDER UNTUK SUB-COLLECTION
          StreamBuilder<QuerySnapshot>(
            stream: AdminService().getJadwalDokter(doctor.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text(
                  'Belum ada jadwal praktik',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                );
              }

              return Column(
                children: snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  // Pastikan DoctorSchedule memiliki factory fromMap yang benar
                  final s = DoctorSchedule.fromMap(data);
                  return _scheduleItem(context, s);
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ... (Widget _infoRow, _scheduleItem, dan _statusBadge tetap sama)
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleItem(BuildContext context, DoctorSchedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(s.day, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${s.start.format(context)} - ${s.end.format(context)}',
            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Nonaktif',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}