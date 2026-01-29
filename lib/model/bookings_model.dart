import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String poli;
  final String photoUrl;
  final String userId;
  final String date;
  final String time;
  final String status; 
  final int queueNumber;
  final DateTime? createdAt; // Dibuat nullable agar tidak error saat data baru dikirim

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.poli,
    required this.photoUrl,
    required this.userId,
    required this.date,
    required this.time,
    required this.status,
    required this.queueNumber,
    this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String documentId) {
    return AppointmentModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      poli: map['poli'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      queueNumber: (map['queueNumber'] as num?)?.toInt() ?? 0,
      // Proteksi jika createdAt null atau masih berupa serverTimestamp di lokal
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'poli': poli,
      'photoUrl': photoUrl,
      'userId': userId,
      'date': date,
      'time': time,
      'status': status,
      'queueNumber': queueNumber, // 🔥 Tambahkan ini agar nomor antrean tersimpan
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}