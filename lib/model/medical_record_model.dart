import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordModel {
  final String bookingId;
  final String patientId;
  final String doctorId;
  final String date;
  final String diagnosa;
  final String resepObat;
  final int biayaKonsultasi;
  final int biayaObat;
  final int totalBayar;
  final DateTime createdAt;

  MedicalRecordModel({
    required this.bookingId,
    required this.patientId,
    required this.doctorId,
    required this.date,
    required this.diagnosa,
    required this.resepObat,
    required this.biayaKonsultasi,
    required this.biayaObat,
    required this.totalBayar,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'patientId': patientId,
      'doctorId': doctorId,
      'date': date,
      'diagnosa': diagnosa,
      'resepObat': resepObat,
      'biayaKonsultasi': biayaKonsultasi,
      'biayaObat': biayaObat,
      'totalBayar': totalBayar,
      'createdAt': createdAt,
    };
  }
}
