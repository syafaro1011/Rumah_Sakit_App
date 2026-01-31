import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import 'package:rumahsakitapp/services/dashboard_patient_service.dart';
import 'package:rumahsakitapp/services/notification_service.dart';
import '../widgets/patient_bottom_nav.dart';

class PatientDashboardPage extends StatefulWidget {
  const PatientDashboardPage({super.key});

  @override
  State<PatientDashboardPage> createState() => _PatientDashboardPageState();
}

class _PatientDashboardPageState extends State<PatientDashboardPage> {
  final DashboardPatientService _dashboardService = DashboardPatientService();

  String _formatRupiah(int amount) {
    return "Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";
  }

  @override
  void initState() {
    super.initState();
    NotificationService.init();
    _listenToMedicalUpdates();
  }

  void _listenToMedicalUpdates() {
    final String uid = _dashboardService.currentUserId;

    // 1. Listen ke Antrian (Bookings) & Logika Antrian Sisa 2
    FirebaseFirestore.instance
        .collection('bookings')
        .where('patientId', isEqualTo: uid)
        .where('status', isNotEqualTo: 'Selesai')
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            var data = change.doc.data() as Map<String, dynamic>;
            int myNumber = data['queueNumber'] ?? 0;
            String doctorId = data['doctorId'] ?? '';

            // A. Logika: Dipanggil Dokter (Modified)
            if (change.type == DocumentChangeType.modified) {
              if (data['status'] == 'Dipanggil') {
                NotificationService.showNotification(
                  title: "Giliran Anda! 🏥",
                  body: "Silakan masuk ke ruangan ${data['doctorName']}.",
                );
              }
            }

            // B. Logika: Sisa Antrian 2 (Mendengarkan koleksi 'queues')
            if (doctorId.isNotEmpty) {
              _listenToQueueProgress(doctorId, myNumber);
            }
          }
        });

    // 2. Listen ke Rekam Medis (Notifikasi Pembayaran)
    FirebaseFirestore.instance
        .collection('medical_records')
        .where('patientId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              var data = change.doc.data() as Map<String, dynamic>;
              NotificationService.showNotification(
                title: "Pemeriksaan Selesai ✅",
                body:
                    "Rekam medis tersedia. Silakan bayar ${_formatRupiah(data['totalBayar'] ?? 0)}",
              );
            }
          }
        });
  }

  // Fungsi pembantu untuk memantau progress antrian secara spesifik
  void _listenToQueueProgress(String doctorId, int myNumber) {
    FirebaseFirestore.instance
        .collection('queues')
        .doc(doctorId)
        .snapshots()
        .listen((snap) {
          if (snap.exists) {
            int currentRunning = snap.data()?['currentNumber'] ?? 0;
            if (myNumber == currentRunning + 2 && currentRunning != 0) {
              NotificationService.showNotification(
                title: "Siap-siap! ⚠️",
                body:
                    "2 antrian lagi giliran Anda. Mohon mendekat ke ruang periksa.",
              );
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const PatientBottomNav(currentIndex: 0),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3F6DF6),
        onPressed: () => Navigator.pushNamed(context, AppRoutes.pilihPoli),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<DocumentSnapshot>(
                  future: _dashboardService.getUserProfile(),
                  builder: (context, snapshot) {
                    String name = 'User';
                    if (snapshot.hasData && snapshot.data!.exists) {
                      name = snapshot.data!['nama'] ?? 'User';
                    }
                    return _header(name);
                  },
                ),
                const SizedBox(height: 20),
                _balanceCard(),
                const SizedBox(height: 24),
                _todayPracticeCard(),
                const SizedBox(height: 24),
                const Text(
                  'Layanan Utama',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                _menuCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Booking Dokter',
                  subtitle: 'Buat jadwal praktik',
                  bgColor: const Color(0xFFEAF1FF),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.pilihPoli),
                ),
                _menuCard(
                  icon: Icons.access_time,
                  title: 'Antrian',
                  subtitle: 'Lihat Antrian Online',
                  bgColor: const Color(0xFFFFF4DB),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.queueInfo),
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
      ),
    );
  }

  // ================= UI COMPONENTS =================

  Widget _balanceCard() {
    return StreamBuilder<DocumentSnapshot>(
      // Menggunakan snapshots agar real-time saat saldo berubah
      stream: _dashboardService.getUserProfileStream(),
      builder: (context, snapshot) {
        int balance = 0;
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          balance = data['saldo'] ?? 0;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F6DF6), Color(0xFF6A8DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3F6DF6).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Saldo',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatRupiah(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _dashboardService.topUpSaldo(50000);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text("Kamu telah topup sebesar 50.000"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gagal Top Up: $e")),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Top Up'),
              ),
            ],
          ),
        );
      },
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
}
