import 'package:flutter/material.dart';

class DoctorModel {
  final String id;
  String nama;
  String poli;
  String sip;
  String email;
  String password;
  String phone;
  String experience;
  bool isActive;
  List<DoctorSchedule> schedules;
  String? photoUrl;

  DoctorModel({
    required this.id,
    required this.nama,
    required this.poli,
    required this.sip,
    required this.email,
    required this.password,
    required this.phone,
    required this.experience,
    required this.isActive,
    required this.schedules,
    this.photoUrl,
  });

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'nama': nama,
      'poli': poli,
      'no_SIP': sip,
      'email': email,
      'no_hp': phone,
      'experience': experience,
      'status': isActive ? 'aktif' : 'nonaktif',
      'photoUrl': photoUrl ?? ''
      // HAPUS atau KOMENTARI baris schedules di bawah ini
      // agar dokumen utama tetap bersih saat menggunakan sub-koleksi.
      // 'schedules': schedules.map((s) => s.toMap()).toList(),
    };
  }

  factory DoctorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DoctorModel(
      id: documentId,
      nama: map['nama'] ?? '',
      poli: map['poli'] ?? '',
      sip: map['no_SIP'] ?? '',
      email: map['email'] ?? '',
      password: '',
      phone: map['no_hp'] ?? '',
      experience: map['experience'] ?? '',
      isActive: map['status'] == 'aktif',
      photoUrl: (map['photoUrl'] != null && map['photoUrl'].toString().isNotEmpty) 
              ? map['photoUrl'] 
              : null,
      // PROSES JADWAL DIKOSONGKAN
      // Karena jadwal akan diisi secara terpisah oleh StreamBuilder di Profile Page
      schedules: [],
    );
  }
}

class DoctorSchedule {
  String day;
  TimeOfDay start;
  TimeOfDay end;

  DoctorSchedule({required this.day, required this.start, required this.end});

  Map<String, dynamic> toMap() {
    return {
      'hari': day,
      'jam_mulai':
          '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      'jam_selesai':
          '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
    };
  }

  factory DoctorSchedule.fromMap(Map<String, dynamic> map) {
    TimeOfDay stringToTime(String time) {
      try {
        final parts = time.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      } catch (e) {
        // Jika format salah (misal bukan HH:mm), kembalikan jam default
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }

    return DoctorSchedule(
      day: map['hari'] ?? '',
      start: stringToTime(map['jam_mulai'] ?? '00:00'),
      end: stringToTime(map['jam_selesai'] ?? '00:00'),
    );
  }
}
