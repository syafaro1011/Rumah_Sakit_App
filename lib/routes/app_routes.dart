import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/patient/patient_dashboard_page.dart';
import '../pages/patient/pilih_poli.dart';
// import '../pages/doctor/doctor_dashboard_page.dart';
// import '../pages/admin/admin_dashboard_page.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient/patient-dashboard';
  static const String pilihPoli = '/patient/pilih-poli';
  static const String doctorDashboard = '/doctor/doctor_dashboard';
  static const String adminDashboard = '/admin/admin_dashboard';

  // Map yang berisi daftar rute
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      signup: (context) => const SignUpPage(),
      patientDashboard: (context) => const PatientDashboardPage(),
      pilihPoli: (context) => const PilihPoliPage(),
      // doctorDashboard: (context) => const DoctorDashboard(),
      // adminDashboard: (context) => const AdminDashboard(),
    };
  }
}