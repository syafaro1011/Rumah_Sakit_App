import 'package:cloud_firestore/cloud_firestore.dart';

class BookingsModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String userName; // 🔥 Tambahkan ini (Nama Pasien)
  final String poli;
  final String photoUrl;
  final String userId;
  final String date;
  final String time;
  final String status; 
  final int queueNumber;
  final DateTime? createdAt;

  BookingsModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.userName, // 🔥 Tambahkan ini
    required this.poli,
    required this.photoUrl,
    required this.userId,
    required this.date,
    required this.time,
    required this.status,
    required this.queueNumber,
    this.createdAt,
  });

  factory BookingsModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BookingsModel(
      id: documentId,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      userName: map['userName'] ?? 'Pasien Umum', // 🔥 Tambahkan ini
      poli: map['poli'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      queueNumber: (map['queueNumber'] as num?)?.toInt() ?? 0,
      createdAt: map['createdAt'] is Timestamp 
          ? (map['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'userName': userName, // 🔥 Tambahkan ini agar tersimpan ke Firestore
      'poli': poli,
      'photoUrl': photoUrl,
      'userId': userId,
      'date': date,
      'time': time,
      'status': status,
      'queueNumber': queueNumber,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}