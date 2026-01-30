import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumahsakitapp/routes/app_routes.dart';
import '../../services/doctor_service.dart';
import '../../model/bookings_model.dart';

class JadwalPraktikPage extends StatefulWidget {
  final String doctorId;
  const JadwalPraktikPage({super.key, required this.doctorId});

  @override
  State<JadwalPraktikPage> createState() => _JadwalPraktikPageState();
}

class _JadwalPraktikPageState extends State<JadwalPraktikPage> {
  final DoctorService _doctorService = DoctorService();
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    String dateFilter = DateFormat('d MMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Daftar Antrean",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildHorizontalCalendar(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tanggal: $dateFilter",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const Icon(Icons.filter_list, size: 20, color: Colors.grey),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildPatientList(widget.doctorId, dateFilter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList(String doctorId, String dateFilter) {
    return StreamBuilder<List<BookingsModel>>(
      stream: _doctorService.getBookingsByDate(doctorId, dateFilter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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

            return StreamBuilder<DocumentSnapshot>(
              stream: _doctorService.getUserStream(booking.userId),
              builder: (context, userSnapshot) {
                String displayUserName = "Memuat nama...";
                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  displayUserName = userData['nama'] ?? "Pasien Tanpa Nama";
                }

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      // 1. Validasi Status Selesai/Batal
                      if (booking.status.toLowerCase() == 'success' ||
                          booking.status.toLowerCase() == 'selesai') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Pasien ini sudah selesai diperiksa.",
                            ),
                          ),
                        );
                        return;
                      }

                      // 2. Munculkan Dialog Konfirmasi / Panggil Pasien
                      bool? confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Konfirmasi"),
                          content: Text("Panggil $displayUserName sekarang?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Batal"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3F6DF6),
                              ),
                              child: const Text("Panggil"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        // 3. Update status ke 'checking' di Firestore
                        await _doctorService.updateBookingStatus(
                          booking.id,
                          'checking',
                        );

                        // 4. Navigasi ke Rekam Medis
                        if (mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.rekamMedis,
                            arguments: {
                              'bookingId': booking.id,
                              'userId': booking.userId,
                              'doctorId': booking.doctorId,
                              'nama_pasien': displayUserName,
                              'date': booking.date,
                              'keluhan': 'Keluhan umum',
                            },
                          );
                        }
                      }
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: SizedBox(
                        width: 65,
                        child: Row(
                          children: [
                            Text(
                              "#${booking.queueNumber}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3F6DF6),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F6DF6).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Color(0xFF3F6DF6),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      title: Text(
                        displayUserName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Konsultasi Umum",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                booking.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              booking.status.toUpperCase(),
                              style: TextStyle(
                                color: _getStatusColor(booking.status),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
                  ),
                );
              },
            );
          },
        );
      },
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'success':
      case 'selesai':
        return Colors.green;
      case 'cancelled':
      case 'batal':
        return Colors.red;
      case 'checking':
        return Colors.blue;
      default:
        return Colors.purpleAccent;
    }
  }
}
