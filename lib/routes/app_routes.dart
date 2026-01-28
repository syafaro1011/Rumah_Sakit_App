import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/patient/patient_dashboard_page.dart';
import '../pages/patient/pilih_poli.dart';
// import '../pages/doctor/doctor_dashboard_page.dart';
import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/manage_doctor_page.dart';
import '../pages/admin/doctor_profile_page.dart';
import 'package:rumahsakitapp/model/doctor_model.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String patientDashboard = '/patient/patient-dashboard';
  static const String pilihPoli = '/patient/pilih-poli';
  static const String doctorDashboard = '/doctor/doctor-dashboard';
  static const String adminDashboard = '/admin/admin-dashboard';
  static const String manageDoctor = '/admin/manage-doctor-page';
  static const String doctorProfile = '/admin/doctor-profile-page';

  // Map yang berisi daftar rute
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginPage(),
      signup: (context) => const SignUpPage(),
      patientDashboard: (context) => const PatientDashboardPage(),
      pilihPoli: (context) => const PilihPoliPage(),
      // doctorDashboard: (context) => const DoctorDashboard(),
      adminDashboard: (context) => const AdminDashboardPage(),
      manageDoctor: (context) => const ManageDoctorPage(),
      doctorProfile: (context) {
        final doctor =
            ModalRoute.of(context)!.settings.arguments as DoctorModel;
        return DoctorProfilePage(doctor: doctor);
      },
    };
  }
}
