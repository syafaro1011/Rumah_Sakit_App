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
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final int queueNumber;
  final DateTime createdAt;

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
    required this.createdAt,
  });

  // Konversi dari DocumentSnapshot Firestore ke Object
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
      queueNumber: map['queueNumber'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Konversi dari Object ke Map (jika ingin update data di masa depan)
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
      'createdAt': createdAt,
    };
  }
}