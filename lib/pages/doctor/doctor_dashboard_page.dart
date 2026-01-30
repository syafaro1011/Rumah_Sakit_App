import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/doctor_service.dart';
import '../../model/doctor_model.dart';
import '../../model/bookings_model.dart';
import 'jadwal_praktik_page.dart';

class DoctorDashboardPage extends StatefulWidget {
  const DoctorDashboardPage({super.key});

  @override
  State<DoctorDashboardPage> createState() => _DoctorDashboardPageState();
}

class _DoctorDashboardPageState extends State<DoctorDashboardPage> {
  final DoctorService _doctorService = DoctorService();
  final AuthService _auth = AuthService();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    String dateFilter = DateFormat('d MMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () => _auth.signOut().then(
              (_) => Navigator.pushReplacementNamed(context, '/login'),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder<DoctorModel>(
        stream: _doctorService.getDoctorStream(user?.uid ?? ""),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData)
            return const Center(child: Text("Data tidak ditemukan"));

          final doctor = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(doctor),
                const SizedBox(height: 25),

                // --- STATS JUMLAH PASIEN (REAL-TIME) ---
                _buildQueueSummary(doctor.id, dateFilter),

                const SizedBox(height: 25),
                _buildNavigationBanner(context),
                const SizedBox(height: 25),
                Row(
                  children: [
                    _buildStatCard("Pengalaman", "+${doctor.experience} Tahun"),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      "Status",
                      doctor.isActive ? "Aktif" : "Non-Aktif",
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // --- BAGIAN 1: JADWAL RUTIN ---
                const Text(
                  "Jadwal Praktik",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                StreamBuilder<QuerySnapshot>(
                  stream: _doctorService.getJadwalDokter(doctor.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text(
                        'Belum ada jadwal praktik rutin',
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      );
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        final s = DoctorSchedule.fromMap(
                          doc.data() as Map<String, dynamic>,
                        );
                        return _scheduleItem(context, s);
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 35),

                // --- BAGIAN 2: DAFTAR PASIEN ---
                const Text(
                  "Antrean Pasien",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildHorizontalCalendar(),
                const SizedBox(height: 20),
                Text(
                  "Daftar Pasien Tanggal $dateFilter",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 15),

                _buildPatientList(doctor.id, dateFilter),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET BARU: SUMMARY STATS ---
  Widget _buildQueueSummary(String doctorId, String dateFilter) {
    return StreamBuilder<List<BookingsModel>>(
      // Menggunakan service yang sama dengan List di bawah
      stream: _doctorService.getBookingsByDate(doctorId, dateFilter),
      builder: (context, snapshot) {
        // Jika loading, tampilkan angka 0 atau loading kecil
        int totalPasien = 0;
        if (snapshot.hasData) {
          totalPasien = snapshot.data!.length;
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
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Pasien Perlu Ditangani",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "$totalPasien Orang",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pada Tanggal $dateFilter", // Menunjukkan tanggal yang aktif
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.pending_actions_rounded,
                color: Colors.white,
                size: 40,
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget List Pasien menggunakan Card
  Widget _buildPatientList(String doctorId, String dateFilter) {
    return StreamBuilder<List<BookingsModel>>(
      stream: _doctorService.getBookingsByDate(doctorId, dateFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Column(
              children: [
                Icon(Icons.event_busy, color: Colors.grey, size: 40),
                SizedBox(height: 10),
                Text(
                  "Tidak ada pasien untuk tanggal ini.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final booking = snapshot.data![index];
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F6DF6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: Color(0xFF3F6DF6)),
                ),
                title: Text(
                  booking.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  "Konsultasi Umum",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F6DF6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    booking.time,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- UI Lainnya ---
  Widget _buildHeader(DoctorModel doctor) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFEAF1FF),
            image: (doctor.photoUrl != null && doctor.photoUrl!.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(doctor.photoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: (doctor.photoUrl == null || doctor.photoUrl!.isEmpty)
              ? const Icon(Icons.person, size: 40, color: Color(0xFF3F6DF6))
              : null,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "dr. ${doctor.nama}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              doctor.poli,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              "SIP: ${doctor.sip}",
              style: const TextStyle(
                color: Color(0xFF3F6DF6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _scheduleItem(BuildContext context, DoctorSchedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(s.day, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${s.start.format(context)} - ${s.end.format(context)}',
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalCalendar() {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime date = DateTime.now().add(Duration(days: index));
          bool isSelected =
              DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(selectedDate);

          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3F6DF6)
                    : const Color(0xFFF1F5FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('dd').format(date),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF3F6DF6),
                    ),
                  ),
                  Text(
                    DateFormat('EEE').format(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white70
                          : const Color(0xFF3F6DF6),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7F9),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBanner(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const JadwalPraktikPage()),
      ),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Row(
          children: [
            Icon(Icons.list_alt_rounded, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(
              "Lihat Jadwal Lengkap",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }
}
