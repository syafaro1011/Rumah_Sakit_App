import 'package:flutter/material.dart';

class DoctorModel {
  final String id;
  String name;
  String poli;
  String sip;
  String email;
  String phone;
  String experience;
  bool isActive;
  List<DoctorSchedule> schedules;
  String? photoPath; // NGke ganti ku photoUrl

  DoctorModel({
    required this.id,
    required this.name,
    required this.poli,
    required this.sip,
    required this.email,
    required this.phone,
    required this.experience,
    required this.isActive,
    required this.schedules,
    this.photoPath,
  });
}

class DoctorSchedule {
  String day;
  TimeOfDay start;
  TimeOfDay end;

  DoctorSchedule({required this.day, required this.start, required this.end});
}
