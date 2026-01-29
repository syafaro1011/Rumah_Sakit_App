import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'package:rumahsakitapp/services/dashboard_patient_service.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final DashboardPatientService _dashboardService = DashboardPatientService();
  final int _currentIndex = 0;

  void _handleLogout() async {
    await _dashboardService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: _bottomNav(context),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F6DF6),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.pilihPoli);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<DocumentSnapshot>(
                future: _dashboardService.getUserProfile(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return _header(snapshot.data!['nama'] ?? 'User');
                  }
                  return _header('...');
                },
              ),
              const SizedBox(height: 20),
              _todayPracticeCard(),
              const SizedBox(height: 24),
              _menuCard(
                icon: Icons.calendar_today_outlined,
                title: 'Booking Dokter',
                subtitle: 'Buat jadwal praktik',
                bgColor: const Color(0xFFEAF1FF),
                onTap: () => Navigator.pushNamed(context, AppRoutes.pilihPoli),
              ),
              _menuCard(
                icon: Icons.access_time,
                title: 'Antrian',
                subtitle: 'Lihat Antrian Online',
                bgColor: const Color(0xFFFFF4DB),
                onTap: () => Navigator.pushNamed(context, AppRoutes.queueInfo),
              ),
              _menuCard(
                icon: Icons.description_outlined,
                title: 'Rekam Medis',
                subtitle: 'Riwayat Kesehatan Anda',
                bgColor: const Color(0xFFFFE9E4),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.medicalRecord),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _header(String nama) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, $nama',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Semoga sehat selalu ya!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const Icon(Icons.notifications_none, size: 28),
      ],
    );
  }

  Widget _todayPracticeCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _dashboardService.getTodayBooking(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _emptyBookingCard();
        }

        final doc = snapshot.data!.docs.first;
        final data = doc.data() as Map<String, dynamic>;

        // Handle format tanggal yang aman
        String formattedDate = data['date'] ?? '-';
        String formattedTime = data['time'] ?? '-';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jadwal Terdekat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          backgroundImage:
                              (data['photoUrl'] != null &&
                                  data['photoUrl'] != '')
                              ? NetworkImage(data['photoUrl'])
                              : null,
                          child:
                              (data['photoUrl'] == null ||
                                  data['photoUrl'] == '')
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['doctorName'] ?? 'Dokter',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                data['poli'] ?? 'Umum',
                                style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedTime,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${(data['queueNumber'] ?? 0).toString().padLeft(3, '0')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3F6DF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyBookingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: const [
          Icon(Icons.event_busy, color: Colors.grey, size: 40),
          SizedBox(height: 10),
          Text(
            'Belum ada jadwal praktik hari ini',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.home_outlined,
              color: _currentIndex == 0 ? const Color(0xFF3F6DF6) : Colors.grey,
            ),
            Icon(
              Icons.person_outline,
              color: _currentIndex == 1 ? const Color(0xFF3F6DF6) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
