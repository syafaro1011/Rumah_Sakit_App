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
    'photoUrl': photoUrl,
    // INI KUNCINYA: Jadwal disimpan sebagai array di dalam dokumen yang sama
    'schedules': schedules.map((s) => s.toMap()).toList(), 
  };
}

  // TAMBAHKAN INI: Konversi dari Map Firestore ke Object (Ambil Data)
  factory DoctorModel.fromMap(Map<String, dynamic> map, String documentId) {
    return DoctorModel(
      id: documentId,
      nama: map['nama'] ?? '',
      poli: map['poli'] ?? '',
      sip: map['no_SIP'] ?? '',
      email: map['email'] ?? '',
      password: '', // Password tidak disimpan di doc untuk keamanan
      phone: map['no_hp'] ?? '',
      experience: map['experience'] ?? '',
      isActive: map['status'] == 'aktif',
      photoUrl: map['photoUrl'],
      // PROSES JADWAL DI SINI
      schedules: map['schedules'] != null
          ? List<DoctorSchedule>.from(
              (map['schedules'] as List).map(
                (item) => DoctorSchedule.fromMap(item as Map<String, dynamic>),
              ),
            )
          : [],
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
      'jam_mulai': '${start.hour}:${start.minute.toString().padLeft(2, '0')}',
      'jam_selesai': '${end.hour}:${end.minute.toString().padLeft(2, '0')}',
    };
  }

  // Fungsi untuk membaca dari Firestore
  factory DoctorSchedule.fromMap(Map<String, dynamic> map) {
    // Fungsi pembantu untuk mengubah String "HH:mm" menjadi TimeOfDay
    TimeOfDay stringToTime(String time) {
      final parts = time.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return DoctorSchedule(
      day: map['hari'] ?? '', // Ambil dari 'hari'
      start: stringToTime(
        map['jam_mulai'] ?? '00:00',
      ), // Ambil dari 'jam_mulai'
      end: stringToTime(
        map['jam_selesai'] ?? '00:00',
      ), // Ambil dari 'jam_selesai'
    );
  }
}
