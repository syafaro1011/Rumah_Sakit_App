import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';

class DoctorProfilePage extends StatelessWidget {
  final DoctorModel doctor;

  const DoctorProfilePage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Dokter')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [_header(), const SizedBox(height: 16), _infoCard(context)],
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: doctor.photoPath != null
                ? FileImage(File(doctor.photoPath!))
                : null,
            child: doctor.photoPath == null
                ? const Icon(Icons.person, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doctor.nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(doctor.poli, style: TextStyle(color: Colors.grey.shade600)),
              Text(
                'SIP - ${doctor.sip}',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Informasi Dokter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Chip(
                label: Text(doctor.isActive ? 'Aktif' : 'Nonaktif'),
                backgroundColor: doctor.isActive
                    ? Colors.green.shade100
                    : Colors.red.shade100,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _info(Icons.email, doctor.email),
          _info(Icons.phone, doctor.phone),
          _info(
            Icons.calendar_today,
            doctor.schedules
                .map(
                  (e) =>
                      '${e.day}: ${e.start.format(context)} - ${e.end.format(context)}',
                )
                .join('\n'),
          ),
          const SizedBox(height: 16),
          const Text('Experiences'),
          const SizedBox(height: 6),
          Chip(label: Text('+ ${doctor.experience}')),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
