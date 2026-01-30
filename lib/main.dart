import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rumahsakitapp/pages/admin/admin_dashboard_page.dart';
import 'package:rumahsakitapp/pages/doctor/doctor_dashboard_page.dart';
import 'package:rumahsakitapp/pages/login_page.dart';
import 'package:rumahsakitapp/pages/patient/patient_dashboard_page.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Heal Sync',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primaryColor: const Color(0xFF3F6DF6),
        scaffoldBackgroundColor: Colors.white,
      ),
      // Gunakan AuthWrapper sebagai pintu masuk utama
      home: const AuthWrapper(),
      routes: AppRoutes.getRoutes(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        // Jika user sudah login
        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                // Ambil field 'role' dari Firestore
                String role = roleSnapshot.data!.get('role') ?? 'Pasien';

                // 3. Arahkan berdasarkan role
                if (role == 'admin') {
                  return const AdminDashboardPage(); 
                } else if (role == 'dokter') {
                  return const DoctorDashboardPage(); 
                } else {
                  return const PatientDashboardPage(); 
                }
              }

              // Jika data user di Firestore tidak ditemukan
              return const LoginPage();
            },
          );
        }
        // Jika user belum login
        return const LoginPage();
      },
    );
  }
}