class DoctorModel {
  final String id;
  final String name;
  final String poli;
  final String sip;
  final String email;
  final String phone;
  final String schedule;
  bool isActive;

  DoctorModel({
    required this.id,
    required this.name,
    required this.poli,
    required this.sip,
    required this.email,
    required this.phone,
    required this.schedule,
    this.isActive = true,
  });
}
